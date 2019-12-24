*** Settings ***
Library    JSONSchemaLibrary    schemas/
Library    BuiltIn
Library    OperatingSystem

*** Variables ***
${response}


*** Keywords ***
Check HTTP Response Status Code Is
    [Arguments]    ${expected_status}
    ${status}=    Convert To Integer    ${expected_status}
    Should Be Equal    ${response['status']}    ${status}
    Log    Status code validated

Check HTTP Response Body Json Schema Is
    [Arguments]    ${input}
    Should Contain    ${response['headers']['Content-Type']}    application/json
    ${schema} =    Catenate    SEPARATOR=    ${input}    .schema.json
    Validate Json    ${schema}    ${response['body']}
    Log    Json Schema Validation OK

Should Be Present In Json List
    [Arguments]     ${expr}   ${json_field}   ${json_value}
    Log    Check if ${json_field} is present in ${expr} with the value ${jsonvalue}
    :FOR  ${item}  IN  @{expr}
    \  Exit For Loop If    "${item['${json_field}']}" == "${json_value}"
    Log    Item found ${item}
    [return]    ${item}

Check Result Contains
    [Arguments]    ${source}    ${parameter}    ${value}
    Should Be Present In Json List    ${source}    ${parameter}    ${value}

Check ProblemDetails
    [Arguments]    ${expected_status}
    ${status}=    Convert To Integer    ${expected_status}
    Should Be Equal    ${response['body']['problemDetails']['status']}    ${status}
    Log    ProblemDetails Status code validated
    
Check HTTP Response Header Contains
    [Arguments]    ${HEADER_TOCHECK}
    Should Contain     ${response['headers']}    ${HEADER_TOCHECK}
    Log    Header is present

Check HTTP Response Body is Empty
    Should Be Empty    ${response['body']}   
    Log    Body is empty
    
Check HTTP Response Contain Header with value
    [Arguments]    ${HEADER_TOCHECK}    ${VALUE}
    Check HTTP Response Header Contains    ${HEADER_TOCHECK}
    Should Be Equal As Strings    ${value}    ${response['headers']['Content-Type']}    


