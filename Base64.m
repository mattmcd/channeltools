classdef Base64
    %BASE64 package for encoding and decoding messages into base64 
    
    properties
    end
    
    methods (Static)
        function outStr = encode(inStr)
            % Encode an input string into base 64
            
            inStrCount = numel(inStr);
            % Need to pad with zeros to a multiple of 3 bytes
            padByteCount = mod(3 - mod(inStrCount,3),3);
            inStr((end+1):(end+padByteCount)) = char(0);
            % Convert to array of bytes
            inBytes = uint8(inStr);
            % Reshape to 3xN array
            inBytes = reshape(inBytes, 3, []);
            % Split into 6 byte chunks
            outBytes = [...
                bitshift(inBytes(1,:),-2);...
                bitor(bitshift(bitand(inBytes(1,:),3),4),bitshift(inBytes(2,:),-4));...
                bitor(bitshift(bitand(inBytes(2,:),15),2),bitshift(inBytes(3,:),-6));...
                bitand(inBytes(3,:),63)];
            outStr = arrayfun(@Base64.mapping,outBytes);
            outStr = outStr(:)';
            outStr = [outStr repmat('=',1,padByteCount)];
        end
        
        function outChar = mapping(inByte)
            % Mapping from 6 bits to output character
            mapArray = [char('A'+(0:25)) char('a'+(0:25)) ...
                char('0'+(0:9)) '+/'];
            outChar = mapArray(inByte+1);
        end
    end
    
end

