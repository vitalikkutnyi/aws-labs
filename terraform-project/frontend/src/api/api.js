const API_URL = "https://eydevtyoc8.execute-api.eu-central-1.amazonaws.com/dev";

export const getTasks = () =>
  fetch(`${API_URL}/tasks`).then(res => res.json());

export const getUsers = async () => {
  const res = await fetch(`${API_URL}/users`);
  const data = await res.json();

  if (typeof data.body === "string") {
    return JSON.parse(data.body);
  }

  return data;
};

export const getTask = (id) =>
  fetch(`${API_URL}/tasks/${id}`).then(res => res.json());

export const createTask = (task) =>
  fetch(`${API_URL}/tasks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(task),
  });

export const updateTask = (id, task) =>
  fetch(`${API_URL}/tasks/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(task),
  });

export const deleteTask = (id) =>
  fetch(`${API_URL}/tasks/${id}`, {
    method: "DELETE",
  });