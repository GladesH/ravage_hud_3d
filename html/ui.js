const panel = document.getElementById('panel');
const titleEl = document.getElementById('title');
const listEl = document.getElementById('list');

let state = { theme: 'ravage', title: 'Interaction', options: [], index: 1 };

function render(){
  titleEl.textContent = state.title || 'Interaction';
  listEl.innerHTML = '';

  (state.options || []).forEach((o, i) => {
    const row = document.createElement('div');
    row.className = 'item' + (i + 1 === state.index ? ' selected' : '');
    if (o.icon) {
      const img = document.createElement('img');
      img.src = o.icon;
      img.style.width = '18px';
      img.style.height = '18px';
      img.style.objectFit = 'contain';
      row.appendChild(img);
    }
    const txt = document.createElement('div');
    txt.textContent = o.label || ('Option ' + (i+1));
    row.appendChild(txt);
    listEl.appendChild(row);
  });
}

function applyTheme(){
  panel.classList.remove('tech', 'ravage');
  panel.classList.add(state.theme === 'tech' ? 'tech' : 'ravage');
}

onmessage = (e) => {
  const msg = e.data; // DUI: payload déjà objet
  if (!msg || !msg.action) return;

  if (msg.action === 'open') {
    state.theme = msg.theme || 'ravage';
    state.title = msg.title || 'Interaction';
    state.options = msg.options || [];
    state.index = msg.index || 1;
    applyTheme();
    render();
    panel.classList.remove('hidden');
  }

  if (msg.action === 'index') {
    state.index = msg.index || 1;
    render();
  }

  if (msg.action === 'update') {
    state.options = msg.options || [];
    state.index = msg.index || 1;
    render();
  }

  if (msg.action === 'theme') {
    state.theme = msg.theme || 'ravage';
    applyTheme();
  }

  if (msg.action === 'close') {
    panel.classList.add('hidden');
  }
};

document.addEventListener('DOMContentLoaded', () => {
  panel.classList.add('hidden');
  applyTheme();
});
