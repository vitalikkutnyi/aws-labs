const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const id = event.pathParameters ? event.pathParameters.id : null;
    
    let body;
    try {
        body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    } catch (e) {
        return callback(null, { statusCode: 400, body: JSON.stringify({ message: "Invalid JSON" }) });
    }

    const { name, userId } = body || {};

    if (!id || !name || !userId) {
        return callback(null, {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing id, name or userId" })
        });
    }

    const params = {
        TableName: "tasks",
        Key: { id: { S: id } },
        UpdateExpression: "SET #n = :name, userId = :userId",
        ExpressionAttributeNames: { "#n": "name" },
        ExpressionAttributeValues: {
            ":name": { S: name },
            ":userId": { S: userId }
        },
        ReturnValues: "ALL_NEW"
    };

    dynamodb.updateItem(params, (err, data) => {
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
            const updatedTask = {
                id: data.Attributes.id ? data.Attributes.id.S : id,
                name: data.Attributes.name ? data.Attributes.name.S : name,
                userId: data.Attributes.userId ? data.Attributes.userId.S : userId
            };
            response.statusCode = 200;
            response.body = JSON.stringify(updatedTask);
        }
        
        callback(null, response);
    });
};
