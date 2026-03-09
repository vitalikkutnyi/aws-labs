const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id } = event;  // припустимо, id передається в event
    const params = { TableName: "courses", Key: { id: { S: id } } };

    dynamodb.getItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, data.Item);
    });
};