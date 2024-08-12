export function response(ctx) {
    if (ctx.error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: "Error: " + ctx.error.message
            })
        };
    }

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Item successfully created"
        })
    };
}
