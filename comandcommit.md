Passo a Passo:
Verifique em qual branch você está:

bash

git branch

Mude para a branch desejada (ou crie uma nova):

Para mudar: git checkout nome-da-branch
Para criar e mudar: git checkout -b nova-branch

Adicione e comite suas alterações:

bash

git add .
git commit -m "Sua mensagem de commit"

Envie o commit para o repositório remoto:

bash

git push origin nome-da-branch