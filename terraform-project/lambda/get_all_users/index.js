const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = { TableName: "users" };

    dynamodb.scan(params, (err, data) => {
        const response = {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        };

        if (err) {
            response.statusCode = 500;
            response.body = JSON.stringify({ error: err.message });
            callback(null, response);
        } else {
            const users = data.Items.map(item => ({
                id: item.id ? item.id.S : null,
                firstName: item.firstName ? item.firstName.S : null,
                lastName: item.lastName ? item.lastName.S : null
            }));

            response.statusCode = 200;
            response.body = JSON.stringify(users);
            
            callback(null, response);
        }
    });
};
