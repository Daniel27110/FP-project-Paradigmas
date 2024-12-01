declare


    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE INSTRUCTIION TREE CLASS
    % /////////////////////////////////////////////////////////////////////////////

    class TreeClass

        % The tree is a binary tree with the following structure:
        % 1. Left nodes: Operators
        % 2. Right nodes: Parameters

        % Attributes
        attr value left right 

        % Constructor
        meth init(Value)
            value := Value
            left := nil
            right := nil
        end

        % Setters
        meth setLeft(Left)
            left := Left
        end

        meth setRight(Right)
            right := Right
        end

        % Getters
        meth getValue($)
            @value
        end

        meth getLeft($)
            @left
        end

        meth getRight($)
            @right
        end

        % Inorder traversal
        meth inorder(List $)

            % List is allways a cell
            (TreeClass,inorderHelper(List @left @right))
            {Cell.access List}

        end

        meth inorderHelper(ListCell Left Right)

            % left
            if Left \= nil then
                % {Cell.assign ListCell {ListCell.append {Cell.access ListCell} {Left.inorder()}}}
                if {Cell.access ListCell} == nil then
                    {Cell.assign ListCell {Left inorder(ListCell $)}}
                else
                    {Cell.assign ListCell {List.append {Cell.access ListCell} {Left inorder({Cell.new nil} $)}}}
                end
            end

            % root
            if {Cell.access ListCell} == nil then

                {Cell.assign ListCell [@value]}
                %{Browse {Cell.access ListCell}}
            else
                {Cell.assign ListCell {List.append {Cell.access ListCell} [@value]}}

            end

            % right
            if Right \= nil then
                % {Cell.assign ListCell {ListCell.append {Cell.access ListCell} {Right.inorder()}}}
                if {Cell.access ListCell} == nil then
                    {Cell.assign ListCell {Right inorder(ListCell $)}}
                else
                    {Cell.assign ListCell {List.append {Cell.access ListCell} {Right inorder({Cell.new nil} $)}}}
                end
            end


        end


        % Print tree in inorder traversal
        meth treeStructure($)

            (TreeClass,inorder({Cell.new nil} $))

        end

    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE PARSER OBJECT - OUR KNOWLEDGE BASE FOR THE PARSER
    % /////////////////////////////////////////////////////////////////////////////

    class ParserClass

        % Attributes
        attr parameters parameterList

        % Constructor
        meth init()
            parameters := parameters()
            parameterList := nil
        end

        % Parameters
        % Parameters represents a separate structure that will be used to store the VALUES of the parameters in a record
        % This structure represents the memory of the program

        meth addParameter(Param ParamValue)
            @parameters := {Record.adjoin @parameters parameter(Param:ParamValue)}
            (ParserClass,addParameterToParameterList(Param))
        end

        meth getParameterValue(Name $)
            {Value.'.' @parameters Name}
        end

        meth getAllParameters($)
            @parameterList
        end

        meth addParameterToParameterList(Param)
            if @parameterList == nil then
                parameterList := [Param]
            else  
                parameterList := {List.append @parameterList Param}
            end
        end
    end

    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE PARSER FUNCTIONS
    % /////////////////////////////////////////////////////////////////////////////

    proc {ParseCode Words}
        
        % Helper function to build the tree
        proc {BuildTree FunctionName Instructions TreeStruc Parser}

            {Browse ['Constructing tree named [' FunctionName '] with instructions' Instructions 'and parameters' {Parser getAllParameters($)}]}

            % Put instructions in prefix form
            {Browse ['  1st. Put instructions in prefix form:' {StringListToAtomList {Infix2Prefix {AtomListToStringList Instructions}}}]}
            
            local PrefixInstructions BuildTreeAux in

                PrefixInstructions = {StringListToAtomList {Infix2Prefix {AtomListToStringList Instructions}}}

                {Browse ['  2nd. Add operations to the left node and parameters to the right node']}

                % Iterate over the instructions, if its an instruction, add it to the left node,
                % if it's a parameter, add it to the right node

                % Tree construction algorithm:
                    % Find the position with the next operator
                    % Get the operator
                    % Get the parameters
                    % Add the operator to the left node if there is only one parameter
                    % if there are more than one parameter, create a new tree with the operator and the single parameter

                % (Realmente es perfectamente posible interpretar la expresión sin necesidad de crear un árbol, pero para efectos de la tarea, se creará un árbol)

                proc {BuildTreeAux PrefixInstructions TreeStruc Parser OpPos}
                    case PrefixInstructions of H|T then
                        local Op Pa in
                            Op = H
                            Pa = T
                            {Browse ['  Operator' Op 'Parameters' Pa 'Instructions' PrefixInstructions]}
                            
                            % Recursively add the operator to the left node and the parameters to the right node
                            {AddOperator Op Pa TreeStruc}
                            
                            % % move on to the next character
                            % if Pa == ['@'] then
                            %     {BuildTreeAux T TreeStruc Parser OpPos}
                            % else
                            %     {BuildTreeAux T TreeStruc Parser OpPos + 1}
                            % end
                    
                        end
                    
                    end
                end

                % Call the recursive function
                {BuildTreeAux PrefixInstructions TreeStruc Parser 1}


                % print the tree in a nice visual way
                % {TreeStruc printTree()}

            end
                
            {Browse ['  3rd. Done! The tree inorder structure is:' {TreeStruc treeStructure($)}]}
                
    

        end

    in
        
        local TreeStruc FunctionName Parser in

            % Create a new parser
            Parser = {New ParserClass init()}

            % The first word is allways 'fun', we can ignore it

            % The second word is the function name, that will be the leaf node
            FunctionName = {List.nth Words 2}
            TreeStruc =  {New TreeClass init('@')}


            % The third word onwards MAY be parameters, otherwise its an '='
            % If it's an '=', we can ignore it
            if {List.nth Words 3} == '=' then
                {BuildTree FunctionName {List.drop Words 3} TreeStruc Parser}
            else
                % If it's not an '=', it's a parameter, we add them recursively to the list

                for Param in {Parameters Words 2} do
                    {Browse ['  · Adding parameter' Param]}
                    {Parser addParameter(Param _)}
                end

                {BuildTree FunctionName {List.drop Words {Index Words '='}} TreeStruc Parser}



            end



        end
        
    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE ADD OPERATOR FUNCTION - ADDS AN OPERATOR TO THE LEFT NODE AND PARAMETERS TO THE RIGHT NODE
    % /////////////////////////////////////////////////////////////////////////////

    proc {AddOperator Operator ParametersList TreeStruc}
        % {Browse ['  · Adding operator' Operator 'to the left node and parameters' Parameters 'to the right node']}
        % Calculate the number of parameters, if there is only one, add the operator to the left node
        % and the parameter to the right node
        % if there is more than one, create a new tree, add the first parameter to the right node
        % and call the function recursively with the rest of the parameters and the new tree
        
        if {List.length ParametersList} == 1 then

            {Browse ['  · Adding operator' Operator 'to the left node and parameter' {List.nth ParametersList 1} 'to the right node']}
            % Add the operator to the left node
            {TreeStruc setLeft({New TreeClass init(Operator)})}
            % Add the parameter to the right node
            {TreeStruc setRight({New TreeClass init({List.nth ParametersList 1})})}
        else
            if {List.member {List.nth ParametersList 1} ['+' '-' '*' '/' '=' '(' ')']} then
                % OH LOOK ITS A NEW OPERATOR, ADD IT TO THE RIGHT NODE, ADD A '@' TO THE LEFT NODE AND CALL THE FUNCTION RECURSIVELY
                % CONTINUING THE TREE OVER THE NEW RIGHT NODE
                {Browse ['  · Adding operator' {List.nth ParametersList 1} 'to the right node as a parameter of operator' Operator]}
                {Browse ['  · Creating a new tree to the left node for the other parameter of operator' Operator]}
                % Create a new tree with the operator
                local NewTree in

                    % Add the first parameter to the right of the tree
                    {TreeStruc setRight({New TreeClass init({List.nth ParametersList 1})})}

                    % Create a new tree and set it to the left node
                    NewTree = {New TreeClass init('@')}
                    {TreeStruc setLeft(NewTree)}

                    % % Recursovely repeat the process over this new left tree
                    {AddOperator Operator {List.drop ParametersList 1} NewTree}
                end

            else
                {Browse ['  · Adding parameter ' {List.nth ParametersList 1} 'to the right node as a parameter of operator' Operator]}
                {Browse ['  · Creating a new tree to the left node for the other parameter of operator' Operator]}
                % Create a new tree with the operator
                local NewTree in

                    % Add the first parameter to the right of the tree
                    {TreeStruc setRight({New TreeClass init({List.nth ParametersList 1})})}

                    % Create a new tree and set it to the left node
                    NewTree = {New TreeClass init('@')}
                    {TreeStruc setLeft(NewTree)}

                    % % Recursovely repeat the process over this new left tree
                    {AddOperator Operator {List.drop ParametersList 1} NewTree}
                end

            end
        end


    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE FUNCTION TO RECURSIVELY GET THE POSITION OF A CHARACTER IN A LIST
    % I CAN'T BELIEVE THIS FUNCTION DOESN'T EXIST IN OZ
    % /////////////////////////////////////////////////////////////////////////////

    fun {Index List Element}
        % {Browse ['  Index' List Element]}
        case List of H|T then
            if H == Element then
                1
            else
                1 + {Index T Element}
            end
        [] nil then
            nil
        end
    end
        

    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE PARAMETERS FUNCTION - GETS THE PARAMETERS OF A FUNCTION
    % /////////////////////////////////////////////////////////////////////////////

    fun {Parameters Words OpPos}
        % GET THE PARAMETERS OF THE OPERATION AT THE POSITION OpPos
        % ITS PARAMETERS ARE ALL WORDS AFTER OPPOS AND BEFORE THE NEXT OPERATOR
        % ALL OPERATORS ARE: +, -, *, /, =, (, )
    
        fun {ParametersAux Words Parameters}
            case Words of H|T then
                % {Browse ['  ParametersAux' Words Parameters]}
                if {List.member H ['+' '-' '*' '/' '=' '(' ')']} then
                    % {Browse ['  FOUND AN OPERATOR' H]}
                    Parameters
                    
                else
                    % {Browse ['  FOUND A PARAMETER' H]}
                    if Parameters == nil then
                        {ParametersAux T [H]}
                    else
                        {ParametersAux T {List.append Parameters [H]}}
                    end
                end
            else
                Parameters
            end
        end
    
    in
        {Browse ['  FINDING PARAMETERS AMONG' {List.drop Words OpPos}]}
        {ParametersAux {List.drop Words OpPos} nil}
    end

    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE SPLIT FUNCTION - SPLIT THE CODE INTO WORDS
    % /////////////////////////////////////////////////////////////////////////////

    fun {Split Code}
        % iterate until finding a space
        fun {SplitAux Code Words Cumulative}

            case {AtomToString Code} of
                nil then 
                    if Cumulative == nil then
                        {List.append Words nil}
                    else
                        {List.append Words [Cumulative]}
                    end 

            [] 32|Rest then
                % 32 represents the ASCII code for space
                % {Browse 'Found a space!'}
                % {Browse ['  Cumulative' Cumulative]}

                % 1. add the cumulative to the words list
                % 2. reset the cumulative 
                % 3. call the function recursively with the rest of the code                
                if Cumulative == nil then
                    {SplitAux {String.toAtom Rest} Words nil}
                else
                    {SplitAux {String.toAtom Rest} {List.append Words [Cumulative]} nil}
                end

            [] 40 | Rest then
                % 40 represents the ASCII code for '('
                % {Browse 'Found a parenthesis!'}
                % {Browse ['  Cumulative' Cumulative]}

                % 1. add the cumulative to the words list
                % 2. reset the cumulative AND THE PARANTHESIS
                % 3. call the function recursively with the rest of the code
                if Cumulative == nil then
                    {SplitAux {String.toAtom Rest} {List.append Words ['(']} nil}
                else
                    {SplitAux {String.toAtom Rest} {List.append {List.append Words [Cumulative]} ['(']} nil}
                end

            [] 41 | Rest then
                % 41 represents the ASCII code for ')'
                % {Browse 'Found a parenthesis!'}
                % {Browse ['  Cumulative' Cumulative]}

                % 1. add the cumulative to the words list
                % 2. reset the cumulative AND THE PARANTHESIS
                % 3. call the function recursively with the rest of the code
                if Cumulative == nil then
                    {SplitAux {String.toAtom Rest} {List.append Words [')']} nil}
                else
                    {SplitAux {String.toAtom Rest} {List.append {List.append Words [Cumulative]} [')']} nil}
                end

            [] Char|Rest then
                % Char represents the ASCII code for a character different from space or parenthesis (aka a letter part of a word)

                % check if the character is read correctly
                %{Browse ['code:' Code 'char:' {String.toAtom Char | nil} 'cumulative:' Cumulative]}

                % if it's not a space, it's a character
                % iterates over the code string until it finds a space using a new list
                % {SplitAux {String.toAtom Rest} Words 'hi'}
                if Cumulative == nil then
                    {SplitAux {String.toAtom Rest} Words {String.toAtom Char | nil}}
                else
                    {SplitAux {String.toAtom Rest} Words {Concatenate Cumulative {String.toAtom Char | nil}}}
                end

            end
        end
        
    in
        {SplitAux Code nil nil}
    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE INFIX TO PREFIX FUNCTION - CONVERTS AN INFIX EXPRESSION TO A PREFIX EXPRESSION
    % TAKES A LIST OF STRINGS LIKE ["(", "X", "+", "Y", ")"] AND RETURNS A LIST OF STRINGS LIKE ["+" "X" "Y"]
    % (THESE ARE STRINGS NOT ATOMS!) 
    % /////////////////////////////////////////////////////////////////////////////
    
    fun {Infix2Prefix Data}
        local Reverse Infix2Postfix in
            fun {Reverse Data Ans}
                case Data of H|T then
                    case H of "(" then
                        {Reverse T ")"|Ans}
                    []  ")" then
                        {Reverse T "("|Ans}
                    else
                        {Reverse T H|Ans}
                    end
                else
                    Ans
                end
            end
            fun {Infix2Postfix Data Stack Res}
                local PopWhile in
                    fun {PopWhile Stack Res Cond}
                        case Stack of H|T then
                            if {Cond H} then
                                {PopWhile T H|Res Cond}
                            else
                                [Res Stack]
                            end
                        else
                            [Res Stack]
                        end
                    end
                    case Data of H|T then
                        case H of "(" then
                            {Infix2Postfix T H|Stack Res}
                        [] ")" then
                            local H2 T2 T3 in
                                H2|T2|nil = {PopWhile Stack Res fun {$ X} {Not X=="("} end}
                                _|T3 = T2
                                {Infix2Postfix T T3 H2}
                            end 
                        [] "+" then
                            local H2 T2 in
                                H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X ["*" "/"]} end}
                                {Infix2Postfix T H|T2 H2}
                            end
                        [] "-" then
                            local H2 T2 in
                                H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X ["*" "/"]} end}
                                {Infix2Postfix T H|T2 H2}
                            end
                        [] "*" then
                            local H2 T2 in
                                H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X nil} end}
                                {Infix2Postfix T H|T2 H2}
                            end
                        [] "/" then
                            local H2 T2 in
                                H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X nil} end}
                                {Infix2Postfix T H|T2 H2}
                            end
                        else
                            {Infix2Postfix T Stack H|Res}
                        end
                    else 
                        Res
                    end
                end
            end
            {Infix2Postfix "("|{Reverse "("|Data nil} nil nil}
        end
    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE ATOM LIST TO STRING LIST FUNCTION - CONVERTS A LIST OF ATOMS TO A LIST OF STRINGS
    % /////////////////////////////////////////////////////////////////////////////

    fun {AtomListToStringList AtomList}
        
        fun {AtomToStringAux AtomList StringList}
            case AtomList of H|T then
                
                if StringList == nil then
                    {AtomToStringAux T [{AtomToString H}]}
                else
                    {AtomToStringAux T {List.append StringList [{AtomToString H}]}}
                end

            else
                StringList
            end
        end
    in 
        {AtomToStringAux AtomList nil}
    end

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE STRING LIST TO ATOM LIST FUNCTION - CONVERTS A LIST OF STRINGS TO A LIST OF ATOMS
    % /////////////////////////////////////////////////////////////////////////////

    fun {StringListToAtomList StringList}
        
        fun {StringToAtomAux StringList AtomList}
            case StringList of H|T then
                
                if AtomList == nil then
                    {StringToAtomAux T [{String.toAtom H}]}
                else
                    {StringToAtomAux T {List.append AtomList [{String.toAtom H}]}}
                end

            else
                AtomList
            end
        end
    in
        {StringToAtomAux StringList nil}
    end


    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE CONCATENATE FUNCTION - CONCATENATE TWO ATOMS
    % /////////////////////////////////////////////////////////////////////////////

    fun {Concatenate Atom1 Atom2}
        % Check the concatenation is done correctly
        % {Browse ['  Concatenate' Atom1 '+' Atom2]}
        % {Browse ['  Result'  {String.toAtom {List.append {AtomToString Atom1} {AtomToString Atom2}}}]}
        
        % return the concatenation of the two atoms
        {String.toAtom {List.append {AtomToString Atom1} {AtomToString Atom2}}}
    end


local Code Call in

    % /////////////////////////////////////////////////////////////////////////////
    % TEST CASES
    % EACH TEST CASE HAS A DEFINITION AND A CALL, AS DEFINED BY THE REQUIREMENTS
    % /////////////////////////////////////////////////////////////////////////////

    % /////////////////////////////////////////////////////////////////////////////
    % TEST CASE 1
    % DEFINITION: fun twice x = x + x
    % CALL: twice 5
    % /////////////////////////////////////////////////////////////////////////////

    Code = 'fun sum x = x + x * x'
    Call = 'sum 5'
    {Browse ['FIRST TEST CASE']}
    {Browse ['Code:' Code]}
    {Browse ['Call:' Call]}

    {Browse '---'}

    {ParseCode {Split Code}}
    


    % /////////////////////////////////////////////////////////////////////////////
end
