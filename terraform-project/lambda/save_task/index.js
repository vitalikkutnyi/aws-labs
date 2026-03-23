const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    let body;
    try {
        body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    } catch (e) {
        return callback(null, {
            statusCode: 400,
            body: JSON.stringify({ message: "Invalid JSON format" })
        });
    }

    const { id, name, userId } = body || {};

    if (!id || !name || !userId) {
        return callback(null, {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing required fields: id, name, or userId" })
        });
    }

    const params = {
        TableName: "tasks",
        Item: {
            id: { S: id },
            name: { S: name },
            userId: { S: userId }
        }
    };

    dynamodb.putItem(params, (err, data) => {
        const response = {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        };

        if (err) {
            response.statusCode = 500;
            response.body = JSON.stringify({ error: err.message });
        } else {
            response.statusCode = 201;
            response.body = JSON.stringify({ message: "Task saved", taskId: id });
        }
        
        callback(null, response);
    });
};
