%%%---RC4---%%%  
function  Keystream = RC4 (Input_key,Input_plaintext)
                                      
    Key = uint16(PRGA(KSA(Input_key), size(Input_plaintext,2))); 
    PlainText = uint16(char(Input_plaintext));
    CipherText = bitxor(Key, PlainText);
    Keystream = bitxor(PlainText, CipherText);
   
%Function for KSA
function [ S ] = KSA( key )

    key = char(key);
    key = uint16(key);
    
    key_length = size(key,2);
    S=0:255;
    
    j=0;
    for i=0:1:255
        j =  mod( j + S(i+1) + key(mod(i, key_length) + 1), 256);
        S([i+1 j+1]) = S([j+1 i+1]);
    end


%Function for PRGA
function [ key ] = PRGA( S, n )
    %S is the result from KSA function
    %n is the number of characters to be encrypted
    
    i = 0;
    j = 0;
    key = uint16([]);
    %each iteration we will append one key value
    
    while n> 0
        n = n - 1;
        i = mod( i + 1, 256);
        j = mod(j + S(i+1), 256);
        S([i+1 j+1]) = S([j+1 i+1]);
        K = S( mod(  S(i+1) + S(j+1)   , 256)  + 1  );
        key = [key, K];
           
    end
%%%---End of RC4---%%% 