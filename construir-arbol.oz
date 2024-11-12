declare
    % Function to parse the code string and build the tree
    fun {ParseCode Words}
        
        % Helper function to build the tree
        fun {BuildTree Words}
            case Words of
                nil then nil
            [] 'fun'|Rest then
                case Rest of
                    Name|Rest2 then
                        case Rest2 of
                            '='|Rest3 then
                                {BuildTree Rest3}
                            [] _ then
                                {BuildTree Rest2}
                        end
                end
            [] '('|Rest then
                {BuildTree Rest}
            [] ')'|Rest then
                {BuildTree Rest}
            [] Operator|Rest then
                case Operator of
                    '+' then
                        left = {BuildTree Rest}
                        right = {BuildTree Rest}
                        tree(left: left operator: '+' right: right)
                    [] '-' then
                        left = {BuildTree Rest}
                        right = {BuildTree Rest}
                        tree(left: left operator: '-' right: right)
                    [] '*' then
                        left = {BuildTree Rest}
                        right = {BuildTree Rest}
                        tree(left: left operator: '*' right: right)
                    [] '/' then
                        left = {BuildTree Rest}
                        right = {BuildTree Rest}
                        tree(left: left operator: '/' right: right)
                    [] _ then
                        tree(value: Operator)
                end
            [] _ then
                tree(value: Words.0)
            end
        end

    in 
        {BuildTree Words}
    end

    % Function to split the code string into words
    fun {Split Code}
        % iterate until finding a space
        fun {SplitAux Code Words Cumulative}

            case {AtomToString Code} of
                nil then Words

            [] 32|Rest then
                % 32 represents the ASCII code for space
                {Browse 'SPACE'}
                {SplitAux Rest {String.toAtom Rest} | Words nil}

            [] Char|Rest then
                {Browse ['code:' Code 'char:' {String.toAtom Char | nil} 'cumulative:' Cumulative]}
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

    % Concatenate two atoms into a single one
    fun {Concatenate Atom1 Atom2}
        {Browse ['  Concatenate' Atom1 '+' Atom2]}
        % {Browse ['  Result'  {AtomToString Atom1} |  {AtomToString Atom2} | nil ]}
        % {Browse ['  Result'  {List.append {AtomToString Atom1} {AtomToString Atom2}}]}
        {Browse ['  Result'  {String.toAtom {List.append {AtomToString Atom1} {AtomToString Atom2}}}]}
        
        % return the concatenation of the two atoms
        {String.toAtom {List.append {AtomToString Atom1} {AtomToString Atom2}}}
    end


local Code Words Tree in

    % Example usage
    Code = 'fun sqr x = (x+1) * (x-1)'
    {Browse Code}
    
    {Browse '---'}

    Words = {Split Code}
    {Browse Words}

    {Browse '---'}

    Tree = {ParseCode Words}
    {Browse Tree}
end