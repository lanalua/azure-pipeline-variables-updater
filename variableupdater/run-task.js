const tl = require("azure-pipelines-task-lib/task");
const axios = require("axios").default;

async function main()
{
    try
    {
        const token = tl.getEndpointAuthorizationParameter('SystemVssConnection', 'AccessToken', false);
        const groupID = tl.getInput("VariableGroupId", true),
            varName = tl.getInput("VariableName", true),
            newValue = tl.getInput("NewValue", true);
        const groupURL = `${process.env.SYSTEM_TEAMFOUNDATIONCOLLECTIONURI}${process.env.SYSTEM_TEAMPROJECTID}/_apis/distributedtask/variablegroups/${groupID}?api-version=4.1-preview.1`;
        const axConf = {headers: {"Authorization": `Bearer ${token}`}};

        const group = (await axios.get(groupURL, axConf)).data,
            vars = group.variables
        //AzDevOps var names are case insensitive while JavaScript objects are case sensitive
        const varEntry =  Object.entries(vars).find(([key]) => key.toLowerCase() == varName.toLowerCase());
        if(varEntry)
        {
            console.log(`Old value: ${varEntry[1].value}`);
            varEntry[1].value = newValue;
        }
        else
            vars[varName] = {value: newValue};
        console.log(`New value: ${newValue}`);
        await axios.put(groupURL, group, axConf);
    }
    catch(exc)
    {
        tl.setResult(tl.TaskResult.Failed, exc.message, true);
        if(exc.stack)
            console.log(exc.stack);
    }
}

main();