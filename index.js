const util = require("util");

const exec = util.promisify(require("child_process").exec);
const rg = require("./rg");
const express = require("express");
const fs = require("fs");
const _ = require("lodash");

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
    const searchTerm = req.params.query.split("&")[0];
    const page = req.params.query.split("&")[1];
    const pageNum = _.defaultTo(
        page ? page.replace("page=","") * 100 : 100,
        100
    );
    if (!searchTerm.match(/^[0-9a-zA-Z,-,+]+$/)) {
        res.status(400).send("search query does not match alphanum");
        return;
    }
    if (searchTerm.length < 3) {
        res.status(400).send("");
        return;
    }
    const rgResults = await rg(basePath, searchTerm);
    const sortedRgResults = _.sortBy(rgResults, "file");
    const searchResult = sortedRgResults.slice(pageNum - 100, pageNum);
    searchResult.forEach((v) => delete v.column);
    res.send({ hits: sortedRgResults.length, results: searchResult });
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
