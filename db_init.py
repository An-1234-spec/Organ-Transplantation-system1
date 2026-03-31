import mysql.connector
from mysql.connector import Error
import os

DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': ''
}

def setup_db():
    conn = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        print("Creating database `organ_transplant_db`...")
        cur.execute("CREATE DATABASE IF NOT EXISTS organ_transplant_db")
        cur.execute("USE organ_transplant_db")
        
        # Read the SQL file
        sql_file = 'organ_transplant_db-org (1).sql'
        if not os.path.exists(sql_file):
            print(f"Error: {sql_file} not found!")
            return

        print(f"Executing {sql_file} schema...")
        with open(sql_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
            
        # Robust splitting logic for MySQL dumps with DELIMITERS
        commands = []
        current_command = []
        in_delimiter_block = False
        delimiter = ';'
        
        lines = sql_content.split('\n')
        for line in lines:
            stripped = line.strip()
            if not stripped or stripped.startswith('--') or stripped.startswith('/*'):
                continue
                
            if stripped.upper().startswith('DELIMITER'):
                new_delim = stripped.split()[1]
                if new_delim == ';':
                    in_delimiter_block = False
                    delimiter = ';'
                else:
                    in_delimiter_block = True
                    delimiter = new_delim
                continue
            
            current_command.append(line)
            if not in_delimiter_block and stripped.endswith(';'):
                commands.append('\n'.join(current_command))
                current_command = []
            elif in_delimiter_block and stripped.endswith(delimiter):
                # Remove the custom delimiter from the end before storing
                cmd = '\n'.join(current_command)
                commands.append(cmd.rstrip().rstrip(delimiter))
                current_command = []

        for command in commands:
            if command.strip():
                try:
                    cur.execute(command)
                except Error as e:
                    if "already exists" not in str(e).lower():
                        print(f"Command error: {e}\nCommand: {command[:100]}...")
        
        # ─── AUTO-UPGRADE: Ensure Recipient has Status column ───
        try:
            print("Checking for pending database upgrades...")
            cur.execute("ALTER TABLE recipient ADD COLUMN Status varchar(20) DEFAULT 'Waiting'")
            print("Upgraded Recipient table with Status column.")
        except Error as e:
            # Error 1060: Duplicate column name
            if e.errno != 1060:
                print(f"Upgrade notice: {e}")
        
        conn.commit()
        print("Database setup successfully!")
        
    except Error as e:
        print(f"DB Setup error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    setup_db()
