const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB.DocumentClient({
  region: "eu-central-1"
});

exports.handler = async (event) => {
  try {
    const data = await dynamodb.scan({
      TableName: "users"
    }).promise();

    const users = data.Items.map(item => ({
      id: item.id,
      firstName: item.firstName,
      lastName: item.lastName
    }));

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(users)
    };

  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};