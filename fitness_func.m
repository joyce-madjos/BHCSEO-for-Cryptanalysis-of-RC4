%%%---Fitness Fucntion---%%%  
function ffit = fitness_func(keystream_from_bhcseo, rc4)

    oneS = 0; 
    zeroeS = 0;
    Km= uint16(rc4);                                     % Goal KeyStream
    K1m= uint16(keystream_from_bhcseo);                  % KeyStream from BHCSEO
    xor_op = bitxor(Km, K1m);                           % xor operation of 2 keystreams                     
    binary = dec2bin(xor_op);
        
        for i = 1:numel(binary)                         % Count the number of zeroes 
            
            if binary(i) == '0'
                     zeroeS = zeroeS+1; 
            else  
                    oneS = oneS+1; 
          
            end

        end

  length = numel( binary);                            % Computes the length of Keystream
  ffit = zeroeS / length;                             % The Fitness Function
%%%---End of Fitness Fucntion---%%%  