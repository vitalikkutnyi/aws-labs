import React, { useEffect, useState } from "react";
import { getUsers, createTask } from "../api/api";

const TaskForm = ({ onCreated }) => {
  const [name, setName] = useState("");
  const [userId, setUserId] = useState("");
  const [users, setUsers] = useState([]);

  useEffect(() => {
    getUsers().then(setUsers);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!name || !userId) return;

    await createTask({
      id: Date.now().toString(),
      name,
      userId,
    });

    setName("");
    setUserId("");

    if (onCreated) onCreated();
  };

  return (
    <form onSubmit={handleSubmit} className="container">
      <h3>Create Task</h3>

      <input
        placeholder="Task name"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />

      <select value={userId} onChange={(e) => setUserId(e.target.value)}>
        <option value="">Select user</option>
        {users.map((u) => (
          <option key={u.id} value={u.id}>
            {u.firstName} {u.lastName}
          </option>
        ))}
      </select>

      <button type="submit">Create</button>
    </form>
  );
};

export default TaskForm;