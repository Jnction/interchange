#!/usr/bin/env node
'use strict';

import fs from 'fs';
import * as path from 'node:path';

const inputFile = process.argv[2];
if (inputFile === undefined) {
    throw new Error('The path to routes.json must be specified as the fiurst argument');
}
const agencies = process.argv.length > 3 ? process.argv.slice(3) : null;
const data = JSON.parse(fs.readFileSync(inputFile, 'utf-8'));

for (const agency in data) {
    if (data.hasOwnProperty(agency) && (agencies === null || agencies.includes(agency))) {
        const routes = data[agency];
        const content = `ID="${agency}"
GTFS="https://dev.aubin.app/gtfs/agencies/${agency}.zip"
GTFSRT="https://data.bus-data.dft.gov.uk/api/v1/gtfsrtdatafeed/?routeId=${encodeURIComponent(routes.join(','))}&api_key=${process.env.API_KEY}"
`;
        fs.writeFileSync(path.join(import.meta.dirname, 'agencies', `${agency}.env`), content);
    }
}

