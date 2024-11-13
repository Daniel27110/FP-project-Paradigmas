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
                {SplitAux {String.toAtom Rest} {List.append Words [Cumulative]} nil}

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
                % check the character is read correctly
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
end
