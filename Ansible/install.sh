

# ansible 설치 
apt-get install software-properties-common \
apt-add-repository ppa:ansible/ansible \
apt-get update \ 
apt-get install ansible


# 신규 인벤토리 파일 생성 
mkdir test && cd $_

echo "192.168.21.214" >> customized_inven.lst 
echo "192.168.21.32" >> customized_inven.lst   
cat customized_inven.lst 


# 신규 인벤토리 파일을 실행
ansible -i customized_inven.lst all -m ping -k 
ansible -i customized_inven.lst 192.168.21.214 -m ping -k 


# [ 패스워드 없이 실행 ]

# ssh key 등록 
ssh-keygen -t rsa
cd .ssh 
ls 

# 관리대상 서버에 퍼블릭 키 복사 
ssh-copy-id root@192.168.21.214
ssh-copy-id root@192.168.21.32  //okestro2018

ansible all -m ping 
ansible all -m shell -a "uptime"


# [ Ansible ad-hoc command ]

# 인벤토리 등록 호스트 확인 
ansible all --list-hosts
cat /etc/ansible/hosts

# -m ping 
ansible all -m ping -k  // -k는 비밀번호 

# -m shell
ansible all -m shell -a "df -h" // a는 argument 

# -m user
ansible all -m user -a "name-user01"  // # useradd user01
ansible all -m user -a "name-user01 state=absent" # userdel user01



# [ play book ]

git clone https://github.com/devops-book/ansible-playbook-sample.git

cd ansible-playbook-sample # Clone 한 디렉토리로 이동 
ansible-playbook -i development site.yml

