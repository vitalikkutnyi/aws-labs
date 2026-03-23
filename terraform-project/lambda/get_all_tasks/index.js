const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = { TableName: "tasks" };

    dynamodb.scan(params, (err, data) => {
        if (err) {
            callback(null, {
                statusCode: 500,
                headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
                body: JSON.stringify({ error: err.message })
            });
        } else {
            const tasks = data.Items.map(item => ({
                id: item.id ? item.id.S : null,
                name: item.name ? item.name.S : null,
                userId: item.userId ? item.userId.S : null
            }));

            const response = {
                statusCode: 200,
                headers: {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                body: JSON.stringify(tasks)
            };
            
            callback(null, response);
        }
    });
};
