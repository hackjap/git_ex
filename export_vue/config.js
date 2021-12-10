

//config.js

const config = (() => {
    return {
      "VUE_CONFIG_APP_API": "...",
    };
  })();



// index.html
  <script src="<%= BASE_URL %>config.js"></script>



// eslintrc.js
globals: {
    config: "readable",
  },







  apiVersion: v1
kind: ConfigMap
metadata:
  name: fe-config
  namespace: ...
data:
  config.js: |
    var config = (() => {
      return {
        "VUE_CONFIG_APP_API": "...",
      };
    })();





    