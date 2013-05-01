
# Function to get cli-safe values that we can use with node's exec function
module.exports = (arg) -> (''+arg).replace(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/gm, '\\').replace(/\n/g, "'\n'").replace(/^$/, "''")
