# LuLu@NufuturoUFCG

LuLu é uma aplicação de firewall macOS gratuita.

**To Build:** 

Clone o repositório localmente:

    git clone https://github.com/nufuturo-ufcg/LuLu.git

Importe o projeto no Xcode, e faça um novo build. Siga esse tutorial: `https://docs.google.com/document/d/1-DZV9pKRMM_kchNusm5jgPEu7KCGOqac18vQJQHui84/edit`  

Mova o LuLu.app, disponível no xcode build folder, para o diretório /Applications.

**To run LuLu headless:** 

Simplismente rode o comando:
(Caso necessário conceder permissões de privacidade e segurança, apenas siga as instruções apple)

    /Applications/LuLu.app/Contents/MacOS/LuLu -headless &

**To test LuLu headless:** 

Uso: 

	python passive_mode_test.py <rule_id> <expected_verdict>

Exemplo: `rules.plist` possui a regra `92058E71-0DD9-....` para `bloquear` todas as conexões de saída para a applicação `curl`:
	
	python passive_mode_test.py curl google.com 92058E71-0DD9-4EB4-AAAF-93A5D82FB098 BLOCK

Exemplo: `rules.plist` possui a regra `EDAB7BD0-D3BD-....` para `permitir` todas as conexões de saída para a applicação `curl`:
	
	python passive_mode_test.py curl google.com EDAB7BD0-D3BD-419B-9E92-BC88B8918A75 ALLOW

Exemplo: `Não possui regra` para a applicação `curl`:
	
	python passive_mode_test.py curl google.com PASSIVE_MODE ALLOW

O seu teste deve apresentar um resultado semelhante ao do vídeo:

https://github.com/user-attachments/assets/6b0facc5-9a4d-46f8-95bc-bf48c9375071

 



