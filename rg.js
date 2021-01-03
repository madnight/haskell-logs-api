'use strict';

const exec = require('child_process').exec;

function RipgrepError(error, stderr) {
  this.message = error;
  this.stderr = stderr;
}

function formatResults(stdout) {
  stdout = stdout.trim();

  if (!stdout) {
    return [];
  }
  stdout = stdout.split("\n")
  stdout.sort()
  return stdout.map((line) => new Match(line));
}

module.exports = function ripGrep(cwd, options, searchTerm) {
  if (arguments.length === 2 && typeof options === 'string') {
    searchTerm = options;
    options = {};
  }

  if (!cwd) {
    return Promise.reject('No `cwd` provided');
  }

  if (arguments.length === 1) {
    return Promise.reject('No search term provided');
  }

  options.regex = options.regex || '';
  options.globs = options.globs || [];
  options.string = searchTerm || options.string || '';

  let execString = 'rg --column --max-count 1 --line-number --color never';
  if (options.regex) {
    execString = `${execString} -e ${options.regex}`;
  } else if (options.string) {
    execString = `${execString} -F ${options.string}`;
  }

  execString = options.globs.reduce((command, glob) => {
    return `${command} -g '${glob}'`;
  }, execString);

  return new Promise(function(resolve, reject) {
    const oneGigaByte = 1024 * 1024 * 1024;
    exec(execString, { cwd, maxBuffer: oneGigaByte }, (error, stdout, stderr) => {
      if (!error || (error && stderr === '')) {
        resolve(formatResults(stdout));
      } else {
        reject(new RipgrepError(error, stderr));
      }
    });
  });
};

class Match {
  constructor(matchText) {
    matchText = matchText.split(':');

    this.file = matchText.shift();
    this.line = parseInt(matchText.shift());
    this.column = parseInt(matchText.shift());
    this.match = matchText.join(':');
  }
}

module.exports.Match = Match;
