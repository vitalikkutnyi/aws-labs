const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const id = event.pathParameters ? event.pathParameters.id : null;

    if (!id) {
        return callback(null, {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing task ID in path" })
        });
    }

    const params = { 
        TableName: "tasks", 
        Key: { "id": { S: id } } 
    };

    dynamodb.deleteItem(params, (err, data) => {
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
            response.statusCode = 200;
            response.body = JSON.stringify({ message: "Task deleted", taskId: id });
        }

        callback(null, response);
    });
};
