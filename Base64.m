classdef Base64
    %BASE64 package for encoding and decoding messages into base64 
    
    % Copyright 2009 The MathWorks Ltd
    % Author: Matt McDonnell (matt.mcdonnell@mathworks.co.uk)
  
    properties (Constant = true)
        ToBase64Mapping = [char('A'+(0:25)) char('a'+(0:25)) ...
                char('0'+(0:9)) '+/'];
        ByteArray = uint8(0:63);            
    end
    
    methods (Static)
        function outStr = encode(inBytes)
            % Encode an input byte array into base 64
            
            inByteCount = numel(inBytes);
            % Need to pad with zeros to a multiple of 3 bytes
            padByteCount = mod(3 - mod(inByteCount,3),3);
            inBytes((end+1):(end+padByteCount)) = uint8(0);
            % Reshape to 3xN array
            inBytes = reshape(inBytes, 3, []);
            % Split into 6 byte chunks
            outBytes = [...
                bitshift(inBytes(1,:),-2);...
                bitor(bitshift(bitand(inBytes(1,:),3),4),bitshift(inBytes(2,:),-4));...
                bitor(bitshift(bitand(inBytes(2,:),15),2),bitshift(inBytes(3,:),-6));...
                bitand(inBytes(3,:),63)];
            % Convert to char array
            outStr = Base64.ToBase64Mapping(outBytes(:)+1);
            % Make the output string a row vector
            outStr = outStr(:)';
            % Add padding indicator characters
            outStr((end-padByteCount+1):end) = '=';
        end
        
        function outBytes = decode(inStr)
            % Decode from base 64 to character array
            
            % Find pad bytes
            padStr = inStr((end-2):end);
            padByteCount = sum(double(padStr) == double('='));
            % Create lookup table from ASCII value to base64 value
            lookupTable = zeros(255,1,'uint8');
            lookupTable(double(Base64.ToBase64Mapping)) = uint8(Base64.ByteArray);
            % Convert to byte array
            inBytes = lookupTable(inStr);
            % Reshape into 4xN matrix for vectorised transformation
            inBytes = reshape(inBytes,4,[]);
            % Combine the 6 bit chunks into bytes
            outBytes = [...
                bitor(bitshift(inBytes(1,:),2), bitshift(inBytes(2,:),-4));...
                bitor(bitshift(bitand(inBytes(2,:),15),4), bitshift(inBytes(3,:),-2));...
                bitor(bitshift(bitand(inBytes(3,:),3),6), inBytes(4,:))];
            outBytes = outBytes(:)';
            % Remove the pad bytes
            outBytes((end-padByteCount+1):end) = [];
        end        
    end
    
end

