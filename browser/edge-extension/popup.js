const STORAGE_KEY = "travel_pal_notes_v1";
const MAX_NOTES = 40;

const noteEl = document.getElementById("note");
const placeEl = document.getElementById("place");
const saveBtn = document.getElementById("save");
const clearBtn = document.getElementById("clear");
const listEl = document.getElementById("notes");
const emptyEl = document.getElementById("empty");

function storageArea() {
  if (typeof browser !== "undefined" && browser.storage?.local) {
    return browser.storage.local;
  }
  return chrome.storage.local;
}

async function loadNotes() {
  const data = await storageArea().get(STORAGE_KEY);
  return Array.isArray(data[STORAGE_KEY]) ? data[STORAGE_KEY] : [];
}

async function saveNotes(notes) {
  await storageArea().set({ [STORAGE_KEY]: notes });
}

function formatWhen(ts) {
  try {
    return new Date(ts).toLocaleString(undefined, {
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
    });
  } catch {
    return "";
  }
}

function render(notes) {
  listEl.innerHTML = "";
  const has = notes.length > 0;
  emptyEl.hidden = has;
  clearBtn.hidden = !has;

  for (const item of notes) {
    const li = document.createElement("li");
    if (item.place) {
      const place = document.createElement("div");
      place.className = "place";
      place.textContent = item.place;
      li.appendChild(place);
    }
    const text = document.createElement("div");
    text.className = "text";
    text.textContent = item.text;
    li.appendChild(text);

    const meta = document.createElement("div");
    meta.className = "meta";
    const when = document.createElement("span");
    when.textContent = formatWhen(item.createdAt);
    const del = document.createElement("button");
    del.type = "button";
    del.className = "delete";
    del.textContent = "Remove";
    del.addEventListener("click", async () => {
      const next = (await loadNotes()).filter((n) => n.id !== item.id);
      await saveNotes(next);
      render(next);
    });
    meta.append(when, del);
    li.appendChild(meta);
    listEl.appendChild(li);
  }
}

saveBtn.addEventListener("click", async () => {
  const text = noteEl.value.trim();
  if (!text) {
    noteEl.focus();
    return;
  }
  const notes = await loadNotes();
  notes.unshift({
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    text,
    place: placeEl.value.trim(),
    createdAt: Date.now(),
  });
  const trimmed = notes.slice(0, MAX_NOTES);
  await saveNotes(trimmed);
  noteEl.value = "";
  placeEl.value = "";
  render(trimmed);
  noteEl.focus();
});

clearBtn.addEventListener("click", async () => {
  if (!confirm("Clear all saved notes?")) return;
  await saveNotes([]);
  render([]);
});

loadNotes().then(render);
