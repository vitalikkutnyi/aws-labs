import React, { useEffect, useState } from "react";
import { getTasks, deleteTask, getUsers, updateTask } from "../api/api";

const TaskList = () => {
  const [tasks, setTasks] = useState([]);
  const [users, setUsers] = useState([]);

  const [editingTask, setEditingTask] = useState(null);
  const [name, setName] = useState("");
  const [userId, setUserId] = useState("");

  const load = async () => {
    const [t, u] = await Promise.all([getTasks(), getUsers()]);
    setTasks(t);
    setUsers(u);
  };

  useEffect(() => {
    load();
  }, []);

  const getUserName = (userId) => {
    const user = users.find((u) => u.id === userId);
    return user ? `${user.firstName} ${user.lastName}` : "Unknown";
  };

  const handleDelete = async (id) => {
    await deleteTask(id);
    load();
  };

  const handleEdit = (task) => {
    setEditingTask(task.id);
    setName(task.name);
    setUserId(task.userId);
  };

  const handleUpdate = async () => {
    await updateTask(editingTask, { name, userId });
    setEditingTask(null);
    setName("");
    setUserId("");
    load();
  };

  return (
    <div className="container">
      <h3>Tasks</h3>

      {tasks.map((t) => (
        <div key={t.id} className="task-card">
          <p className="task-header">Task: {t.name}</p>
          <p className="task-user">User: {getUserName(t.userId)}</p>

          <div className="task-actions">
            <button onClick={() => handleEdit(t)}>Edit</button>
            <button onClick={() => handleDelete(t.id)}>Delete</button>
          </div>
        </div>
      ))}

      {editingTask && (
        <div className="edit-box">
          <h3>Edit Task</h3>

          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Task name"
          />

          <select value={userId} onChange={(e) => setUserId(e.target.value)}>
            <option value="">Select user</option>
            {users.map((u) => (
              <option key={u.id} value={u.id}>
                {u.firstName} {u.lastName}
              </option>
            ))}
          </select>

          <button onClick={handleUpdate}>Save</button>
        </div>
      )}
    </div>
  );
};

export default TaskList;