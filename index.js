const util = require("util");
const exec = util.promisify(require("child_process").exec);
const rg = require("ripgrep-js");
const express = require("express");
const fs = require("fs");

const app = express();
const port = 3000;
const basePath = process.env.SEARCH_DIRECTORY;

if (!basePath) {
    process.stderr.write(
        "Please provide SEARCH_DIRECTORY environment variable\n"
    );
    process.exit(1);
}

app.get("/search/:query", async (req, res) => {
    res.header("Access-Control-Allow-Origin", "*");
    const searchTerm = req.params.query;
    if (!searchTerm.match(/^[0-9a-z,-]+$/)) {
        res.status(400).send("search query does not match alphanum");
        return;
    }
    const rgResults = await rg(basePath, searchTerm);
    const searchResult = rgResults.slice(0, 100);
    searchResult.forEach((v) => delete v.column);
    res.send(searchResult);
});

app.get("/file/:year/:month/:name", async (req, res) => {
    res.header("Access-Control-Allow-Origin", "*");
    const { year, month, name } = req.params;
    try {
        const fileName = basePath + year + "/" + month + "/" + name;
        fs.createReadStream(fileName).pipe(res);
    } catch (e) {
        console.log("Error:", e.stack);
    }
});

app.listen(port, () => {});
