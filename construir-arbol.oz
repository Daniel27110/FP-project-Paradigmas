declare


    %% /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE INSTRUCTIION TREE CLASS
    %% /////////////////////////////////////////////////////////////////////////////

    class Tree

        % 1. leaf nodes: representing constants (numbers) or variables
        % 2. @ nodes: representing function applications

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


    end

    %% /////////////////////////////////////////////////////////////////////////////
    %  DEFINITION OF THE PARSER FUNCTIONS
    %% /////////////////////////////////////////////////////////////////////////////

    fun {ParseCode Words}
        
        % Helper function to build the tree
        fun {BuildTree Words Tree}
            {Browse ['Constructing tree named [' {{Tree getLeft(($))} getValue($)} '] with instructions' Words ]}

            % Iterate over the words list
            1
            % if the 
            
            % Check if the first word is a variable

        end

    in
        
        local TreeStruc FunName in
            % The first word is allways 'fun', we can ignore it

            % The second word is the function name, that will be the leaf node
            % Remember the structure:
                % root node: @
                % left node: function name
                % right node: function body
            FunName = {List.nth Words 2}

            TreeStruc =  {New Tree init('@')}
            {TreeStruc setLeft({New Tree init(FunName)})}


            % The third word is allways '=', we can ignore it
            % From the fourth word onwards, we can start building the tree
            {BuildTree {List.drop Words 4} TreeStruc}

        end
        
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


local Code Call Words Tree in

    % /////////////////////////////////////////////////////////////////////////////
    % TEST CASES
    % EACH TEST CASE HAS A DEFINITION AND A CALL, AS DEFINED BY THE REQUIREMENTS
    % /////////////////////////////////////////////////////////////////////////////

    % /////////////////////////////////////////////////////////////////////////////
    % TEST CASE 1
    % DEFINITION: fun twice x = x + x
    % CALL: twice 5
    % /////////////////////////////////////////////////////////////////////////////

    Code = 'fun square x = (x * x)'
    Call = 'square 5'
    {Browse ['FIRST TEST CASE']}
    {Browse ['Code:' Code]}
    {Browse ['Call:' Call]}

    {Browse '---'}

    Words = {Split Code}
    Tree = {ParseCode Words}
    {Browse Tree}


    % /////////////////////////////////////////////////////////////////////////////
    
    % TEST THE list of atoms to string function
    {Browse {AtomListToStringList ['(' 'x' '*' 'y' ')']}}

    % TEST THE PREORDER FUNCTION
    {Browse {Infix2Prefix {AtomListToStringList ['(' 'x' '*' 'y' ')']}}}

    % TEST THE STRING TO ATOM LIST FUNCTION
    {Browse {StringListToAtomList {Infix2Prefix {AtomListToStringList ['(' 'x' '*' 'y' ')']}}}}
end
