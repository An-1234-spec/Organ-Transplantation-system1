from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error
from datetime import date
import json

app = Flask(__name__)
app.secret_key = 'organ_transplant_secret_2026'

DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': '',
    'database': 'organ_transplant_db'
}

def get_db():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"DB Error: {e}")
        return None

def query_db(sql, args=(), one=False, commit=False):
    conn = get_db()
    if not conn:
        return None
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, args)
        if commit:
            conn.commit()
            return cur.lastrowid
        
        # Consuming all results if multiple sets exist (for procedures)
        rv = cur.fetchall() if cur.with_rows else None
        while cur.nextset():
            pass
            
        return (rv[0] if rv else None) if one else (rv or [])
    except Error as e:
        print(f"Query Error: {e}")
        conn.rollback()
        return None
    finally:
        conn.close()

# ─────────────── DASHBOARD ───────────────
@app.route('/')
def dashboard():
    # Helper to safely extract counts even if a query fails
    def get_count(sql):
        res = query_db(sql, one=True)
        return res['c'] if res and 'c' in res else 0

    stats = {
        'total_donors':        get_count("SELECT COUNT(*) as c FROM donor"),
        'available_donors':    get_count("SELECT COUNT(*) as c FROM donor WHERE Status='Available'"),
        'total_recipients':    get_count("SELECT COUNT(*) as c FROM recipient"),
        'critical_recipients': get_count("SELECT COUNT(*) as c FROM recipient WHERE Urgency_Level=5"),
        'received_recipients': get_count("SELECT COUNT(*) as c FROM recipient WHERE Status='Received'"),
        'total_transplants':   get_count("SELECT COUNT(*) as c FROM transplant_record"),
        'total_hospitals':     get_count("SELECT COUNT(*) as c FROM hospital"),
    }
    organ_dist = query_db("""
        SELECT Organ_Type, COUNT(*) as count
        FROM donor GROUP BY Organ_Type ORDER BY count DESC
    """)
    blood_dist = query_db("""
        SELECT Blood_Group, COUNT(*) as count
        FROM donor GROUP BY Blood_Group ORDER BY count DESC
    """)
    recent_transplants = query_db("""
        SELECT t.Transplant_ID, d.Name as donor_name, r.Name as recipient_name,
               d.Organ_Type, t.Transplant_Date, h.Hospital_Name
        FROM transplant_record t
        JOIN donor d ON t.Donor_ID = d.Donor_ID
        JOIN recipient r ON t.Recipient_ID = r.Recipient_ID
        JOIN hospital h ON t.Hospital_ID = h.Hospital_ID
        ORDER BY t.Transplant_Date DESC LIMIT 5
    """)
    urgency_dist = query_db("""
        SELECT Urgency_Level, COUNT(*) as count
        FROM recipient GROUP BY Urgency_Level ORDER BY Urgency_Level
    """)
    return render_template('dashboard.html',
        stats=stats,
        organ_dist=organ_dist or [],
        blood_dist=blood_dist or [],
        recent_transplants=recent_transplants or [],
        urgency_dist=urgency_dist or []
    )

# ─────────────── DONORS ───────────────
@app.route('/donors')
def donors():
    search  = request.args.get('search', '')
    organ   = request.args.get('organ', '')
    blood   = request.args.get('blood', '')
    status  = request.args.get('status', '')
    sort    = request.args.get('sort', 'Donor_ID')
    order   = request.args.get('order', 'ASC')

    allowed_sorts = ['Donor_ID','Name','Age','Blood_Group','Organ_Type','Donation_Date','Status']
    if sort not in allowed_sorts: sort = 'Donor_ID'
    if order not in ['ASC','DESC']: order = 'ASC'

    sql = """
        SELECT d.*, h.Hospital_Name
        FROM donor d
        LEFT JOIN hospital h ON d.Hospital_ID = h.Hospital_ID
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (d.Name LIKE %s OR d.Blood_Group LIKE %s OR d.Organ_Type LIKE %s)"
        params += [f'%{search}%', f'%{search}%', f'%{search}%']
    if organ:
        sql += " AND d.Organ_Type = %s"
        params.append(organ)
    if blood:
        sql += " AND d.Blood_Group = %s"
        params.append(blood)
    if status:
        sql += " AND d.Status = %s"
        params.append(status)
    sql += f" ORDER BY d.{sort} {order}"

    donors_list = query_db(sql, params)
    hospitals   = query_db("SELECT Hospital_ID, Hospital_Name FROM hospital ORDER BY Hospital_Name")
    return render_template('donors.html',
        donors=donors_list, hospitals=hospitals,
        search=search, organ=organ, blood=blood, status=status,
        sort=sort, order=order,
        total=len(donors_list) if donors_list else 0
    )

@app.route('/donors/add', methods=['POST'])
def add_donor():
    data = request.form
    try:
        query_db("""
            INSERT INTO donor (Name, Age, Blood_Group, Organ_Type, Hospital_ID, Donation_Date, Status)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
        """, (data['name'], data['age'], data['blood_group'], data['organ_type'],
              data['hospital_id'] or None, data['donation_date'], data.get('status','Available')),
        commit=True)
        flash('Donor added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding donor: {e}', 'error')
    return redirect(url_for('donors'))

@app.route('/donors/edit/<int:id>', methods=['POST'])
def edit_donor(id):
    data = request.form
    try:
        query_db("""
            UPDATE donor SET Name=%s, Age=%s, Blood_Group=%s, Organ_Type=%s,
            Hospital_ID=%s, Donation_Date=%s, Status=%s WHERE Donor_ID=%s
        """, (data['name'], data['age'], data['blood_group'], data['organ_type'],
              data['hospital_id'] or None, data['donation_date'], data['status'], id),
        commit=True)
        flash('Donor updated successfully!', 'success')
    except Exception as e:
        flash(f'Error updating donor: {e}', 'error')
    return redirect(url_for('donors'))

@app.route('/donors/delete/<int:id>', methods=['POST'])
def delete_donor(id):
    try:
        query_db("DELETE FROM donor WHERE Donor_ID=%s", (id,), commit=True)
        flash('Donor deleted.', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('donors'))

@app.route('/donors/get/<int:id>')
def get_donor(id):
    donor = query_db("SELECT * FROM donor WHERE Donor_ID=%s", (id,), one=True)
    return jsonify(donor)

# ─────────────── RECIPIENTS ───────────────
@app.route('/recipients')
def recipients():
    search  = request.args.get('search', '')
    organ   = request.args.get('organ', '')
    blood   = request.args.get('blood', '')
    urgency = request.args.get('urgency', '')
    status  = request.args.get('status', '')
    sort    = request.args.get('sort', 'Urgency_Level')
    order   = request.args.get('order', 'DESC')

    allowed_sorts = ['Recipient_ID','Name','Age','Blood_Group','Organ_Required','Urgency_Level','Registration_Date']
    if sort not in allowed_sorts: sort = 'Urgency_Level'
    if order not in ['ASC','DESC']: order = 'DESC'

    sql = """
        SELECT r.*, h.Hospital_Name
        FROM recipient r
        LEFT JOIN hospital h ON r.Hospital_ID = h.Hospital_ID
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (r.Name LIKE %s OR r.Blood_Group LIKE %s OR r.Organ_Required LIKE %s)"
        params += [f'%{search}%', f'%{search}%', f'%{search}%']
    if organ:
        sql += " AND r.Organ_Required = %s"
        params.append(organ)
    if blood:
        sql += " AND r.Blood_Group = %s"
        params.append(blood)
    if urgency:
        sql += " AND r.Urgency_Level = %s"
        params.append(urgency)
    if status:
        sql += " AND r.Status = %s"
        params.append(status)
    sql += f" ORDER BY r.{sort} {order}"

    recipients_list = query_db(sql, params)
    hospitals       = query_db("SELECT Hospital_ID, Hospital_Name FROM hospital ORDER BY Hospital_Name")
    return render_template('recipients.html',
        recipients=recipients_list, hospitals=hospitals,
        search=search, organ=organ, blood=blood, urgency=urgency, status=status,
        sort=sort, order=order,
        total=len(recipients_list) if recipients_list else 0
    )

@app.route('/recipients/add', methods=['POST'])
def add_recipient():
    data = request.form
    try:
        query_db("""
            INSERT INTO recipient (Name, Age, Blood_Group, Organ_Required, Urgency_Level, Registration_Date, Hospital_ID)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
        """, (data['name'], data['age'], data['blood_group'], data['organ_required'],
              data['urgency_level'], data['registration_date'], data['hospital_id'] or None),
        commit=True)
        flash('Recipient added successfully!', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('recipients'))

@app.route('/recipients/edit/<int:id>', methods=['POST'])
def edit_recipient(id):
    data = request.form
    try:
        query_db("""
            UPDATE recipient SET Name=%s, Age=%s, Blood_Group=%s, Organ_Required=%s,
            Urgency_Level=%s, Registration_Date=%s, Hospital_ID=%s, Status=%s WHERE Recipient_ID=%s
        """, (data['name'], data['age'], data['blood_group'], data['organ_required'],
              data['urgency_level'], data['registration_date'], data['hospital_id'] or None, data['status'], id),
        commit=True)
        flash('Recipient updated successfully!', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('recipients'))

@app.route('/recipients/delete/<int:id>', methods=['POST'])
def delete_recipient(id):
    try:
        query_db("DELETE FROM recipient WHERE Recipient_ID=%s", (id,), commit=True)
        flash('Recipient deleted.', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('recipients'))

@app.route('/recipients/get/<int:id>')
def get_recipient(id):
    r = query_db("SELECT * FROM recipient WHERE Recipient_ID=%s", (id,), one=True)
    return jsonify(r)

# ─────────────── HOSPITALS ───────────────
@app.route('/hospitals')
def hospitals():
    search = request.args.get('search', '')
    sql    = "SELECT * FROM hospital WHERE 1=1"
    params = []
    if search:
        sql += " AND (Hospital_Name LIKE %s OR Location LIKE %s OR Contact_Number LIKE %s)"
        params += [f'%{search}%', f'%{search}%', f'%{search}%']
    sql += " ORDER BY Hospital_ID"
    hospitals_list = query_db(sql, params)
    return render_template('hospitals.html',
        hospitals=hospitals_list, search=search,
        total=len(hospitals_list) if hospitals_list else 0
    )

@app.route('/hospitals/add', methods=['POST'])
def add_hospital():
    data = request.form
    try:
        query_db("""
            INSERT INTO hospital (Hospital_Name, Location, Contact_Number)
            VALUES (%s,%s,%s)
        """, (data['hospital_name'], data['location'], data['contact_number']), commit=True)
        flash('Hospital added successfully!', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('hospitals'))

@app.route('/hospitals/edit/<int:id>', methods=['POST'])
def edit_hospital(id):
    data = request.form
    try:
        query_db("""
            UPDATE hospital SET Hospital_Name=%s, Location=%s, Contact_Number=%s
            WHERE Hospital_ID=%s
        """, (data['hospital_name'], data['location'], data['contact_number'], id), commit=True)
        flash('Hospital updated!', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('hospitals'))

@app.route('/hospitals/delete/<int:id>', methods=['POST'])
def delete_hospital(id):
    try:
        query_db("DELETE FROM hospital WHERE Hospital_ID=%s", (id,), commit=True)
        flash('Hospital deleted.', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('hospitals'))

@app.route('/hospitals/get/<int:id>')
def get_hospital(id):
    h = query_db("SELECT * FROM hospital WHERE Hospital_ID=%s", (id,), one=True)
    return jsonify(h)

# ─────────────── TRANSPLANTS ───────────────
@app.route('/transplants')
def transplants():
    search = request.args.get('search', '')
    sort   = request.args.get('sort', 'Transplant_Date')
    order  = request.args.get('order', 'DESC')

    allowed_sorts = ['Transplant_ID','Transplant_Date']
    if sort not in allowed_sorts: sort = 'Transplant_Date'
    if order not in ['ASC','DESC']: order = 'DESC'

    sql = """
        SELECT t.Transplant_ID, t.Transplant_Date,
               d.Donor_ID, d.Name as donor_name, d.Blood_Group as donor_blood,
               d.Organ_Type,
               r.Recipient_ID, r.Name as recipient_name, r.Urgency_Level,
               h.Hospital_ID, h.Hospital_Name
        FROM transplant_record t
        JOIN donor d ON t.Donor_ID = d.Donor_ID
        JOIN recipient r ON t.Recipient_ID = r.Recipient_ID
        JOIN hospital h ON t.Hospital_ID = h.Hospital_ID
        WHERE 1=1
    """
    params = []
    if search:
        sql += """ AND (d.Name LIKE %s OR r.Name LIKE %s
                        OR d.Organ_Type LIKE %s OR h.Hospital_Name LIKE %s)"""
        params += [f'%{search}%', f'%{search}%', f'%{search}%', f'%{search}%']
    sql += f" ORDER BY t.{sort} {order}"

    transplants_list = query_db(sql, params)
    donors    = query_db("SELECT Donor_ID, Name, Organ_Type FROM donor WHERE Status='Available'")
    recipients = query_db("SELECT Recipient_ID, Name, Organ_Required, Urgency_Level FROM recipient ORDER BY Urgency_Level DESC")
    hospitals  = query_db("SELECT Hospital_ID, Hospital_Name FROM hospital ORDER BY Hospital_Name")
    return render_template('transplants.html',
        transplants=transplants_list,
        donors=donors, recipients=recipients, hospitals=hospitals,
        search=search, sort=sort, order=order,
        total=len(transplants_list) if transplants_list else 0
    )

@app.route('/transplants/add', methods=['POST'])
def add_transplant():
    data = request.form
    try:
        query_db("""
            INSERT INTO transplant_record (Donor_ID, Recipient_ID, Transplant_Date, Hospital_ID)
            VALUES (%s,%s,%s,%s)
        """, (data['donor_id'], data['recipient_id'], data['transplant_date'], data['hospital_id']),
        commit=True)
        flash('Transplant recorded successfully!', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('transplants'))

@app.route('/transplants/delete/<int:id>', methods=['POST'])
def delete_transplant(id):
    try:
        query_db("DELETE FROM transplant_record WHERE Transplant_ID=%s", (id,), commit=True)
        flash('Transplant record deleted.', 'success')
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(url_for('transplants'))

# ─────────────── ORGAN MATCHING ───────────────
@app.route('/match')
def match():
    available_donors = query_db("""
        SELECT d.*, h.Hospital_Name FROM donor d
        LEFT JOIN hospital h ON d.Hospital_ID = h.Hospital_ID
        WHERE d.Status = 'Available'
        ORDER BY d.Donation_Date
    """)
    return render_template('match.html', available_donors=available_donors)

@app.route('/match/run/<int:donor_id>')
def run_match(donor_id):
    result = query_db("CALL Match_Organ(%s)", (donor_id,), one=True)
    donor  = query_db("""
        SELECT d.*, h.Hospital_Name FROM donor d
        LEFT JOIN hospital h ON d.Hospital_ID = h.Hospital_ID
        WHERE d.Donor_ID=%s
    """, (donor_id,), one=True)
    return jsonify({'donor': donor, 'match': result})

@app.route('/match/record', methods=['POST'])
def record_match_api():
    data = request.json
    try:
        # Get donor's hospital to pre-fill
        donor = query_db("SELECT Hospital_ID FROM donor WHERE Donor_ID=%s", (data['donor_id'],), one=True)
        hosp_id = donor['Hospital_ID'] if donor else None
        
        query_db("""
            INSERT INTO transplant_record (Donor_ID, Recipient_ID, Transplant_Date, Hospital_ID)
            VALUES (%s, %s, CURDATE(), %s)
        """, (data['donor_id'], data['recipient_id'], hosp_id), commit=True)
        return jsonify({'success': True, 'message': 'Match recorded successfully!'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
