const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id, name, authorId } = event;
    const params = {
        TableName: "courses",
        Key: { id: { S: id } },
        UpdateExpression: "SET #n = :name, authorId = :authorId",
        ExpressionAttributeNames: { "#n": "name" },
        ExpressionAttributeValues: {
            ":name": { S: name },
            ":authorId": { S: authorId }
        },
        ReturnValues: "UPDATED_NEW"
    };

    dynamodb.updateItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, data.Attributes);
    });
};