classdef Base64
    %BASE64 package for encoding and decoding messages into base64 
    
    properties (Constant = true)
        ToBase64Mapping = [char('A'+(0:25)) char('a'+(0:25)) ...
                char('0'+(0:9)) '+/'];
        FromBase64Mapping = double([char('A'+(0:25)) char('a'+(0:25)) ...
                char('0'+(0:9)) '+/']);                
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
            outStr = arrayfun(@Base64.byteToBase64Char,outBytes);
            outStr = outStr(:)';
            outStr = [outStr repmat('=',1,padByteCount)];
        end
        
        function outBytes = decode(inStr)
            % Decode from base 64 to character array
            
            % Find pad bytes
            padStr = inStr((end-2):end);
            padByteCount = sum(double(padStr) == double('='));
            % Remove pad str
            inStr = inStr(1:(end-padByteCount));
            inBytes = arrayfun(@Base64.base64CharToByte,inStr);
            inBytes = reshape(inBytes,4,[]);
            outBytes = [...
                bitor(bitshift(inBytes(1,:),2), bitshift(inBytes(2,:),-4));...
                bitor(bitshift(bitand(inBytes(2,:),15),4), bitshift(inBytes(3,:),-2));...
                bitor(bitshift(bitand(inBytes(3,:),3),6), inBytes(4,:))];
            outBytes = outBytes(:)';
            outBytes((end-padByteCount+1):end) = [];
        end
        
        function outChar = byteToBase64Char(inByte)
            % Mapping from 6 bits to output character
            outChar = Base64.ToBase64Mapping(inByte+1);
        end
        
        function outByte = base64CharToByte(inChar)
            % Mapping from base64 character to byte value
            byteArray = uint8(0:63);
            outByte = byteArray(double(inChar) == Base64.FromBase64Mapping);
        end
    end
    
end

