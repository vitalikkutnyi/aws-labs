const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = { TableName: "courses" };

    dynamodb.scan(params, (err, data) => {
        if (err) {
            callback(err);
        } else {
            const courses = data.Items.map(item => ({
                id: item.id.S,
                name: item.name.S,
                authorId: item.authorId.S
            }));
            callback(null, courses);
        }
    });
};