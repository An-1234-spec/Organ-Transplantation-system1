/* ── main.js — OrganLink global scripts ── */

// ─── Sidebar Clock ───
function updateClock() {
  const el = document.getElementById('sidebar-clock');
  if (!el) return;
  const now = new Date();
  el.textContent = now.toLocaleString('en-IN', {
    dateStyle: 'medium', timeStyle: 'short'
  });
}
updateClock();
setInterval(updateClock, 1000);

// ─── Sidebar Toggle ───
function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('open');
}

// ─── Modal Helpers ───
function openModal(id) {
  const m = document.getElementById(id);
  if (m) { m.classList.add('open'); document.body.style.overflow = 'hidden'; }
}
function closeModal(id) {
  const m = document.getElementById(id);
  if (m) { m.classList.remove('open'); document.body.style.overflow = ''; }
}

// Close modal on overlay click
document.addEventListener('click', function(e) {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('open');
    document.body.style.overflow = '';
  }
});

// Close modal on Escape key
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') {
    document.querySelectorAll('.modal-overlay.open').forEach(m => {
      m.classList.remove('open');
    });
    document.body.style.overflow = '';
  }
});

// ─── Delete Confirm ───
function confirmDelete(url) {
  document.getElementById('delete-form').action = url;
  openModal('delete-modal');
}

// ─── Auto-dismiss flash messages ───
setTimeout(() => {
  document.querySelectorAll('.flash').forEach(f => {
    f.style.opacity = '0';
    f.style.transform = 'translateY(-8px)';
    f.style.transition = 'all 0.4s ease';
    setTimeout(() => f.remove(), 400);
  });
}, 4000);

// ─── Animate stat numbers on dashboard ───
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.stat-number').forEach(el => {
    const target = parseInt(el.textContent);
    if (isNaN(target)) return;
    let current = 0;
    const step = Math.ceil(target / 40);
    const timer = setInterval(() => {
      current = Math.min(current + step, target);
      el.textContent = current;
      if (current >= target) clearInterval(timer);
    }, 25);
  });

  // Global Click Handlers for Edit/Delete
  document.addEventListener('click', (e) => {
    const btnEdit = e.target.closest('.btn-edit');
    const btnDelete = e.target.closest('.btn-delete');

    if (btnEdit && btnEdit.dataset.id) {
      const id = btnEdit.dataset.id;
      if (window.location.pathname.includes('/donors')) editDonor(id);
      if (window.location.pathname.includes('/recipients')) editRecipient(id);
      if (window.location.pathname.includes('/hospitals')) editHospital(id);
    }

    if (btnDelete && btnDelete.dataset.url) {
      confirmDelete(btnDelete.dataset.url);
    }
  });

  // Animate bars after load
  setTimeout(() => {
    document.querySelectorAll('.bar-fill, .urgency-bar, .progress-bar').forEach(bar => {
      const targetWidth = bar.getAttribute('data-percentage');
      if (targetWidth === null) return;
      bar.style.width = '0%';
      requestAnimationFrame(() => {
        setTimeout(() => { bar.style.width = targetWidth + '%'; }, 50);
      });
    });
  }, 100);
});
