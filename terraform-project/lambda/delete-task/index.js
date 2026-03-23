const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id } = event;
    const params = { TableName: "tasks", Key: { id: { S: id } } };

    dynamodb.deleteItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, { message: "Task deleted", taskId: id });
    });
};