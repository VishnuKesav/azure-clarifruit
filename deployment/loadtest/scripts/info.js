import http from 'k6/http';
import {check, sleep} from "k6";

export let options = {
    stages: [
        // Ramp-up from 0 to 50 virtual users (VUs) in 30s
        {duration: "30s", target: 50},

        // Stay at rest on 50 VUs for 60s
        {duration: "60s", target: 50},

        // Ramp-down from 50 to 0 VUs for 30s
        {duration: "30s", target: 0}
    ]
};

export default function () {
    const bearerToken = "Bearer ??";
    const response = http.get("http://localhost:8081/info/all?userId=-5&hidden=true&onlySelected=false", {headers: {Authorization: bearerToken, Accepts: "application/json", "Accept-Encoding": "gzip, deflate"}});
    check(response, {"status is 200": (r) => r.status === 200});
};
