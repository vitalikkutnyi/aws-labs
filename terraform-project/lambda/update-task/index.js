const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id, name, userId } = event;
    const params = {
        TableName: "tasks",
        Key: { id: { S: id } },
        UpdateExpression: "SET #n = :name, userId = :userId",
        ExpressionAttributeNames: { "#n": "name" },
        ExpressionAttributeValues: {
            ":name": { S: name },
            ":userId": { S: userId }
        },
        ReturnValues: "UPDATED_NEW"
    };

    dynamodb.updateItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, data.Attributes);
    });
};