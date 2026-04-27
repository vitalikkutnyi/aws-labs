import React, { useEffect, useState } from "react";
import { getUsers } from "../api/api";

export default function UserList() {
    const [users, setUsers] = useState([]);

    useEffect(() => {
        getUsers().then(setUsers);
    }, []);

    return (
        <div className="container user-list">
            <h2>Users</h2>
            {users.map(u => (
                <div key={u.id}>
                    {u.firstName} {u.lastName}
                </div>
            ))}
        </div>
    );
}