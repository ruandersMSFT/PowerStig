# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    Instructions:  Use this file to add/update/delete regsitry expressions that are used accross
    multiple technologies files that are considered commonly used.  Enure expressions are listed
    from MOST Restrive to LEAST Restrictive, similar to exception handling.  Also, ensure only
    UNIQUE Keys are used in each hashtable to prevent errors and conflicts.
#>

$global:SingleLineRegistryPath += [ordered]@{
    Chrome1 = @{
        Match  = 'Google\\Chrome'
        Select = '((HKLM).*\\Chrome)'
    }
}

$global:SingleLineRegistryValueName += [ordered]@{
    Chrome1 = @{
        Select = '(?<=3. If the a registry value name of )\w+'
    }
    Chrome2 = @{
        Select = '(?<=3. If the value name |3. If this key "|3. If the key ")\w+'
    }
    Chrome3 = @{
        Select = '(?<=3. If the |3. If the ")\w+'
    }
}

$global:SingleLineRegistryValueType += [ordered]@{
    Chrome1 = @{
        Select = '((?<=If the\s)(.*)(?<=DWORD))'
    }
}

$global:SingleLineRegistryValueData += [ordered]@{
    # Added for Outlook Stig V-17776
    Chrome1 = @{
        Select = '(?<=data is not set to |value is not set to |or is not set to ").[^,|\s|"]*'
    }
}
