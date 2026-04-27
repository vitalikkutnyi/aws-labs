import React, { useState } from "react";
import TaskForm from "./components/TaskForm";
import TaskList from "./components/TaskList";
import UserList from "./components/UserList";
import "./App.css";

const App = () => {
  const [reload, setReload] = useState(false);

  return (
    <div className="layout">
      <div className="main">
        <h1>Tasks App</h1>

        <TaskForm onCreated={() => setReload(!reload)} />
        <TaskList key={reload} />
      </div>

      <div className="sidebar">
        <UserList />
      </div>
    </div>
  );
};

export default App;