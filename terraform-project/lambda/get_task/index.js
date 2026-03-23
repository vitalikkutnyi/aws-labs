const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const id = event.pathParameters ? event.pathParameters.id : null;

    if (!id) {
        return callback(null, {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing id in path" })
        });
    }

    const params = { TableName: "tasks", Key: { id: { S: id } } };

    dynamodb.getItem(params, (err, data) => {
        const response = {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        };

        if (err) {
            response.statusCode = 500;
            response.body = JSON.stringify({ error: err.message });
        } else if (!data.Item) {
            response.statusCode = 404;
            response.body = JSON.stringify({ message: "Task not found" });
        } else {
            const task = {
                id: data.Item.id ? data.Item.id.S : null,
                name: data.Item.name ? data.Item.name.S : null,
                userId: data.Item.userId ? data.Item.userId.S : null
            };
            response.statusCode = 200;
            response.body = JSON.stringify(task);
        }
        
        callback(null, response);
    });
};
