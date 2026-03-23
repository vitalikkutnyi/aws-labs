const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id, name, userId } = event;
    const params = {
        TableName: "tasks",
        Item: {
            id: { S: id },
            name: { S: name },
            userId: { S: userId }
        }
    };

    dynamodb.putItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, { message: "Task saved", taskId: id });
    });
};