declare


    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE INSTRUCTIION TREE CLASS
    % /////////////////////////////////////////////////////////////////////////////

    class TreeClass

        % The tree is a binary tree with the following structure:
        % 1. Left nodes: Operators
        % 2. Right nodes: Parameters

        % Attributes
        attr value left right parent

        % Constructor
        meth init(Value)
            value := Value
            left := nil
            right := nil
            parent := nil
        end

        % Setters
        meth setLeft(Left)
            left := Left
            if Left \= nil then
                {Left setParent(self)}
            end
        end

        meth setRight(Right)
            right := Right
            if Right \= nil then
                {Right setParent(self)}
            end
        end

        meth setParent(Parent)
            parent := Parent
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

        meth getParent($)
            @parent
        end

        % Inorder traversal
        meth inorder(List $)

            % List is allways a cell
            (TreeClass,inorderHelper(List @left @right))
            {Cell.access List}

        end

        % Add to TreeClass
        meth printTree()
            local PrintLevel in
                proc {PrintLevel Nodes Level}
                    % If no more nodes to print, we're done
                    if Nodes == nil then
                        skip
                    else
                        % Print current level number
                        {Browse ['Level' Level ':']}
                        
                        % Print values for current level
                        {Browse ['Values:' {Map Nodes fun {$ Node} 
                            if Node == nil then 'nil'
                            else {Node getValue($)} end
                        end}]}
                        
                        % Gather nodes for next level
                        local NextLevel in
                            NextLevel = {FoldL Nodes 
                                fun {$ Acc Node}
                                    if Node == nil then
                                        {Append Acc [nil nil]}
                                    else
                                        {Append Acc [{Node getLeft($)} {Node getRight($)}]}
                                    end
                                end nil}
                            
                            % Check if next level has any non-nil nodes
                            if {All NextLevel fun {$ X} X == nil end} then
                                skip
                            else
                                % Continue with next level
                                {PrintLevel NextLevel Level+1}
                            end
                        end
                    end
                end
                
                % Start printing from root (level 0)
                {Browse '\nTree Structure:'}
                {PrintLevel [self] 0}
            end
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

        % Ensure findNextRedex has debug statements
        meth findNextRedex($)
            % Follow left branch until we find a primitive operator
            local FindPrimitiveOperator GoUpAndCheck in
                
                proc {FindPrimitiveOperator Node ?Result}
                    if Node == nil then
                        Result = nil
                    else 
                        % Check if current node is a primitive operator
                        if {List.member {Node getValue($)} ['+' '-' '*' '/' '=']} then
                            % Found a primitive operator
                            Result = Node
                        elseif {Node getValue($)} == '@' then
                            % Continue searching left branch
                            local LeftNode in
                                LeftNode = {Node getLeft($)}
                                if LeftNode == nil then
                                    Result = nil
                                else
                                    {FindPrimitiveOperator LeftNode Result}
                                end
                            end
                        else
                            Result = nil
                        end
                    end
                end
        
                % Go up the tree a maximum of two times and check right child for '@'
                fun {GoUpAndCheck Node Count}
                    
                    if Node == nil orelse Count == 0 then 
                        Node
                    else
                        local Parent = {Node getParent($)} in
                            if Parent == nil then
                                Node
                            else
                                % Check right child for '@'
                                local RightChild = {Parent getRight($)} in                                    
                                    if RightChild \= nil andthen {RightChild getValue($)} == '@' then
                                        % Move to the right child and start searching from there
                                        local NewPrimitive in
                                            {FindPrimitiveOperator RightChild NewPrimitive}
                                            if NewPrimitive == nil then
                                                {GoUpAndCheck Parent Count-1}
                                            else
                                                % Found a new primitive, start the process again with 2 up moves
                                                {GoUpAndCheck NewPrimitive 2}
                                            end
                                        end
                                    else
                                        {GoUpAndCheck Parent Count-1}
                                    end
                                end
                            end
                        end
                    end
                end
        
                local PrimitiveOp RootNode in
                    % Start from the root node
                    RootNode = self
                    
                    % Find the primitive operator
                    {FindPrimitiveOperator RootNode PrimitiveOp}
                    
                    if PrimitiveOp == nil then
                        nil
                    else
                        % Check for unevaluated arguments, allowing up to two moves up
                        {GoUpAndCheck PrimitiveOp 2}
                    end
                end
            end
        end

        % Evaluate the tree
        meth evaluate(Parser)
            local EvaluateStep in
                proc {EvaluateStep}
                    local RedexNode in
                        RedexNode = {self findNextRedex($)}
                        if RedexNode == nil then
                            {Browse 'No more redexes to evaluate'}
                        else
                            % Get the primitive operator (two nodes to the left)
                            local Primitive Arg1 Arg2 in
                                Primitive = {{RedexNode getLeft($)} getLeft($)}
                                {Browse ['Primitive operator:' {Primitive getValue($)}]}
                                
                                % Get first argument (one node to the left and one to the right)
                                Arg1 = {{RedexNode getLeft($)} getRight($)}
                                {Browse ['Arg1 raw value:' {Arg1 getValue($)} 'type:' {Value.type {Arg1 getValue($)}}]}
                                
                                % Get second argument (one node to the right)
                                Arg2 = {RedexNode getRight($)}
                                {Browse ['Arg2 raw value:' {Arg2 getValue($)} 'type:' {Value.type {Arg2 getValue($)}}]}
                                
                                % Get the actual values (either direct or from parser)
                                local Value1 Value2 Result in
                                    Value1 = try
                                        {String.toInt {Arg1 getValue($)}}
                                    catch _ then
                                        {Parser getParameterValue({Arg1 getValue($)} $)}
                                    end
                                    
                                    Value2 = try
                                        {String.toInt {Arg2 getValue($)}}
                                    catch _ then
                                        {Parser getParameterValue({Arg2 getValue($)} $)}
                                    end
                                    
                                    % Perform the operation
                                    Result = case {Primitive getValue($)}
                                    of '+' then Value1 + Value2
                                    [] '-' then Value1 - Value2
                                    [] '*' then Value1 * Value2
                                    [] '/' then Value1 div Value2
                                    end
                                    
                                    % Update the redex node with the result
                                    {RedexNode setValue(Result)}
                                    {RedexNode setLeft(nil)}
                                    {RedexNode setRight(nil)}
                                    
                                    {Browse ['After evaluation:']}
                                    {Browse ['- Updated tree structure:' {self treeStructure($)}]}
                                    
                                    % Continue evaluation
                                    {EvaluateStep}
                                end
                            end
                        end
                    end
                end
                
                {EvaluateStep}
            end
        end

        % Add setter for value
        meth setValue(Value)
            value := Value
        end
    end

    

    % /////////////////////////////////////////////////////////////////////////////
    % DEFINITION OF THE PARSER OBJECT - OUR KNOWLEDGE BASE FOR THE PARSER
    % /////////////////////////////////////////////////////////////////////////////

    class ParserClass

        % Attributes
        attr parameters parameterList functionName

        % Constructor
        meth init(FunctionName)
            parameters := parameters()
            parameterList := nil
            functionName := FunctionName
        end

        % Parameters
        % Parameters represents a separate structure that will be used to store the VALUES of the parameters in a record
        % This structure represents the memory of the program

        meth addParameter(Param ParamValue)
            parameters := {Record.adjoin @parameters parameter(Param:ParamValue)}
            (ParserClass,addParameterToParameterList(Param))
        end

        % Modified updateParameterValue method to handle integers
        meth updateParameterValue(Param Value)
            try
                % Convert string to integer if it's a number
                local ConvertedValue in
                    ConvertedValue = try 
                        {String.toInt Value}
                    catch _ then
                        % If not a number, keep it as an atom
                        Value
                    end
                    
                    parameters := {Record.adjoinAt @parameters Param ConvertedValue}
                    
                    % Update parameter list
                    local NewParamList in
                        % Remove old parameter without value and add new one with value
                        NewParamList = {List.filter @parameterList fun {$ X} X \= Param end}
                        parameterList := {List.append NewParamList [Param]}
                    end
                end
            catch Ex then
                {Browse ['Error in updateParameterValue:' Ex]}
            end
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
                parameterList := {List.append @parameterList [Param]}
            end
        end
    end

    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE PARSER FUNCTIONS
    % /////////////////////////////////////////////////////////////////////////////

    proc {ParseCode Words ?TreeResult ?ParserResult}
        
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
                            % {Browse ['  Operator' Op 'Parameters' Pa 'Instructions' PrefixInstructions]}
                            
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
            Parser = {New ParserClass init(FunctionName)}

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
                    % {Browse ['  · Adding parameter' Param]}
                    {Parser addParameter(Param _)}
                end

                {BuildTree FunctionName {List.drop Words {Index Words '='}} TreeStruc Parser}



            end

            TreeResult = TreeStruc
            ParserResult = Parser
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

                % if {List.member {List.nth ParametersList 2} ['+' '-' '*' '/' '=' '(' ')']} then
                
                % AN OPERATOR?? IN THE PARAMETER FACTORY? HOW QUEER? I'VE NEVER SEEN SUCH A THING-
                % I GUESS WE'RE MAKING OPERATORS NOW

                % ADD THE NEXT NON OPERATOR PARAMETER TO THE RIGHT NODE
                % ADD A TREE WITH A VALUE OF @ TO THE LEFT NODE, AND THE NEXT OPERATOR TO THE LEFT NODE OF THE NEW TREE AND A @ TO THE RIGHT NODE
                % CONTINUE THE RECURSION OVER THE NEW RIGHT NODE, REMOVING THE FIRST ELEMENT OF THE PARAMETERS LIST AND THE FIRST NON OPERATOR PARAMETER


                % Create a new tree with the operator
                local NewTree NewestList in

                    NewestList = {Remove ParametersList {Index ParametersList {FindNextParameter ParametersList}}}
                    % {Browse ['  · New list' NewestList]}
                    
                    
                    if {List.length NewestList} == 2 then

                        %{Browse ['  IF YOU CAN READ THIS, THINGS HAVE GONE HORRIBLY WRONG, THE LIST IS' NewestList]}
                        % IGNORE THE COMMENT ABOVE, IT'S A LIE, EVERYTHING IS FINE, WE CHILLING

                        % WE'RE IN THE LAST STAGE OF THE TREE, IF WE'RE HERE IS BECAUSE SOME (HORRID) PARENTHESIS WAS USED
                        % BUT WE'RE SMART ENOUGH TO HANDLE IT

                        % PARAMETER LIST SHOULD BE SOMETHING OF THE FORM ['+' '1' 'x'] now.
                        % we've done this before, just put the parameter to the right of the tree, and on the left
                        % put a new tree with value '@' and the operator to the left of the new tree and the last remaining parameter to the right of the new tree

                        % BUT BEFORE THAT PUT THE ACTUAL OPERATOR TO THE LEFT OF THE TREE, AND CREATE A NEW TREE WITH A @ TO THE RIGHT (THIS SOUND SCHIZOPHRENIC BUT TRUST ME ITS A HYPERSPECIFIC CASE)
                        {Browse ['  · Almost done!']}
                        {Browse ['  · Adding operator ' Operator 'to the left node as second to last operator of the tree']}

                        % Add the operator to the left of the tree
                        {TreeStruc setLeft({New TreeClass init(Operator)})}

                        % create a new tree to the right with value '@'
                        NewTree = {New TreeClass init('@')}
                        {TreeStruc setRight(NewTree)}

                        % TRUST THAT OUR ELSE CASE WILL HANDLE THE REST OF THE TREE :D
                        {AddOperator {List.nth ParametersList 1} {List.drop ParametersList 1} NewTree}

                        % % Create a new tree and set it to the left node
                        % NewTree = {New TreeClass init('@')}
                        % {TreeStruc setLeft(NewTree)}

                        % % the leftmost operator is the new operator
                        % {NewTree setLeft({New TreeClass init({List.nth NewestList 1})})}
                        % % the rightmost operator is a new tree with the last remaining parameter
                        % {NewTree setRight({New TreeClass init({FindNextParameter {Remove NewestList {Index NewestList {FindNextParameter NewestList}}}})})} % i hope you're proud of yourselfs

                    else
                        {Browse ['  · Adding ' {FindNextParameter ParametersList} 'to the right node as first parameter of the operator' Operator]}
                        {Browse ['  · Creating a new tree to the left node for the operator' Operator]}
                        {Browse ['  · We"ll now continue with operator' {List.nth ParametersList 1} 'over this new left tree']}

                        % Add the first parameter to the right of the tree
                        {TreeStruc setRight({New TreeClass init({FindNextParameter ParametersList})})}

                        % Create a new tree and set it to the left node
                        NewTree = {New TreeClass init('@')}

                        % the leftmost operator is the new operator
                        {NewTree setLeft({New TreeClass init(Operator)})}

                        % the rightmost operator is a new tree with a value of '@'
                        {NewTree setRight({New TreeClass init('@')})}

                        {TreeStruc setLeft(NewTree)}

                        % % Recursovely repeat the process over this new left tree
                        {AddOperator {List.nth ParametersList 1} {List.drop NewestList 1} {NewTree getRight($)}} % thats the right of the left tree don't panic
                    
                    end
                end


                
                % else 
                %     % OH LOOK ITS A NEW OPERATOR, ADD IT TO THE LEFT NODE, ADD A '@' TO THE RIGHT NODE AND CALL THE FUNCTION RECURSIVELY
                %     % CONTINUING THE TREE OVER THE NEW RIGHT NODE
                %     {Browse ['  · Adding operator' {List.nth ParametersList 1} 'to the left node as a operatora ahead of operator ' Operator]}
                %     {Browse ['  · Creating a new tree to the right node for the other parameter of operator' Operator]}
                %     % Create a new tree with the operator
                %     local NewTree in

                %         % Add the first parameter to the right of the tree
                %         {TreeStruc setLeft({New TreeClass init({List.nth ParametersList 1})})}

                %         % Create a new tree and set it to the left node
                %         NewTree = {New TreeClass init('@')}
                %         {TreeStruc setRight(NewTree)}

                %         % % Recursovely repeat the process over this new left tree
                %         {AddOperator Operator {List.drop ParametersList 1} NewTree}
                %     end
                % end

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
    % DEFINITION OF THE FUNCTION FindNextParameter - This is the last element in the list
    % From left to right that is not an operator, and is not one of the first operators
    % in the list
    % for example, in ['*', '*', 'x', 'y', '+', 'x', '1'], the function would return 'y'
    % /////////////////////////////////////////////////////////////////////////////

    fun {FindNextParameter ListParam}
        fun {FindNextParameterAux ListParam HaveISeenAnOperator LastThingISawThatShouldBeAParameter}
            case ListParam of H|T then
                % {Browse ['  FindNextParameterAux' ListParam HaveISeenAnOperator LastThingISawThatShouldBeAParameter 'H' H]}
                if {List.member H ['+' '-' '*' '/' '=' '(' ')']} then
                    % {Browse 'uwu'}
                    if HaveISeenAnOperator == 'no' then
                        {FindNextParameterAux T 'yes' nil}
                    else
                        if LastThingISawThatShouldBeAParameter == nil then
                            {FindNextParameterAux T 'yes' nil}
                        else
                            LastThingISawThatShouldBeAParameter
                        end
                    end
                else
                    {FindNextParameterAux T HaveISeenAnOperator H}
                end
            else
                LastThingISawThatShouldBeAParameter
            end
        end
    in
        {FindNextParameterAux ListParam 'no' nil}
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
    % DEFINITION OF THE FUNCTION TO REMOVE THE ELEMENT IN A POSITION OF A LIST
    % /////////////////////////////////////////////////////////////////////////////

    fun {Remove List Position}
        % {Browse ['  Remove' List Position]}
        % {Browse ['  Remove' List Position]}
        case List of H|T then
            if Position == 1 then
                T
            else
                H|{Remove T Position - 1}
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
        % {Browse ['  FINDING PARAMETERS AMONG' {List.drop Words OpPos}]}
        {ParametersAux {List.drop Words OpPos} nil}
    end

    % /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE FIRSTNONOPERATORPARAMETER FUNCTION - GETS THE FIRST PARAMETER FROM A LIST OF WORDS THAT IS NOT AN OPERATOR KEYWORD
    % /////////////////////////////////////////////////////////////////////////////

    fun {FirstNonOperatorParameter Words}
        % GET THE FIRST PARAMETER THAT IS NOT AN OPERATOR KEYWORD
        % ALL OPERATORS ARE: +, -, *, /, =, (, )
    
        fun {FirstNonOperatorParameterAux Words}
            case Words of H|T then
                % {Browse ['  FirstNonOperatorParameterAux' Words]}
                if {List.member H ['+' '-' '*' '/' '=' '(' ')']} then
                    % {Browse ['  FOUND AN OPERATOR' H]}
                    {FirstNonOperatorParameterAux T}
                else
                    % {Browse ['  FOUND A PARAMETER' H]}
                    H
                end
            else
                nil
            end
        end
        
    in
        % {Browse ['  FINDING FIRST NON OPERATOR PARAMETER AMONG' Words]}
        {FirstNonOperatorParameterAux Words}
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

    proc {EvaluateCall Parser Call}
        {Browse ['Call:' Call]}
        
        % Split the call into words
        local CallWords ParamValues in
            CallWords = {Split Call}
            {Browse ['CallWords:' CallWords]}
            
            % Get the parameter values (everything after the function name)
            ParamValues = {List.drop CallWords 1}
            {Browse ['ParamValues:' ParamValues]}
            
            % Get the list of parameters from the parser
            local Params = {Parser getAllParameters($)} in
                {Browse ['Parser Parameters:' Params]}
                
                % Debug the zip operation
                local ZippedPairs in
                    ZippedPairs = {List.zip Params ParamValues fun {$ X Y} X#Y end}

                    % Iterate through parameters and assign values
                    try
                        {List.forAll ZippedPairs
                         proc {$ Pair}
                            local Param Value in
                                Param#Value = Pair
                                % Convert string to integer if possible
                                local ConvertedValue in
                                    ConvertedValue = try 
                                        {String.toInt Value}
                                    catch _ then
                                        % If not a number, keep it as an atom
                                        Value
                                    end
                                    
                                    % Update parameter value in parser
                                    {Parser updateParameterValue(Param ConvertedValue)}
                                end
                            end
                         end}
                    catch Ex then
                        {Browse ['Error in parameter update loop:' Ex]}
                    end
                end
            end
        end
    end


% Test case
local Code Call in
    Code = 'fun cubeplusone x = x * x * x + 1' % SHOULD BE 28 (3*3*3+1), TRY x*x*(x+1) FOR 36 (PARENTHESIS DO WORK!! I LOVE PEMDAS)
    Call = 'cubeplusone 3'
    
    local TreeStruc Parser in
        % Get the constructed tree from ParseCode
        {ParseCode {Split Code} TreeStruc Parser}
        
        % Evaluate the call to assign parameter values
        {EvaluateCall Parser Call}
        
        % Print initial tree structure
        {Browse 'Initial tree structure:'}
        {Browse {TreeStruc treeStructure($)}}
        
        % Evaluate the tree until fully reduced
        {TreeStruc evaluate(Parser)}
        
        % Print final tree structure
        {Browse 'Final tree structure:'}
        {Browse {TreeStruc treeStructure($)}}
    end
end