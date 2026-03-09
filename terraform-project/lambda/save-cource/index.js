const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const { id, name, authorId } = event;
    const params = {
        TableName: "courses",
        Item: {
            id: { S: id },
            name: { S: name },
            authorId: { S: authorId }
        }
    };

    dynamodb.putItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, { message: "Course saved", courseId: id });
    });
};