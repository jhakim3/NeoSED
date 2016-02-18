function [ stretchedInputs ] = lengthEqualizer(varargin)


maxLength = max([length(varargin{1}), length(varargin{2}), length(varargin{3})]);

stretchedInputs=zeros(3,maxLength);

for i=1:3
    vararg=varargin{i};
    varLength=length(vararg);
    
    if (varLength)==0
       error('Error 1'); 
    end
    
    for j=1:floor(maxLength/varLength)
        
        stretchedInputs(i,(j-1)*varLength+1:j*varLength) = vararg(1:end);
    end
    
    
    if ~(length(vararg)==(maxLength))
        
        startind=floor(maxLength/varLength)*length(vararg)+1;
        
        stretchedInputs(i,startind:end) = vararg(randi(length(vararg),1,maxLength-startind+1));
    end
end

end

