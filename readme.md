# K8s setup Scripts

This is how to run the script

## Basic Script
### IN 2 seperate commands
```bash
rm basic.sh; wget https://raw.githubusercontent.com/MGertz/k8s/main/basic.sh
```
```bash
sudo bash basic.sh
```


### In one command
```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/basic.sh | sudo sh
```



# Final way of calling the different scripts
## Master Script
```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/master.sh | sudo sh
```

## Node Script
```bash
curl -fsSL https://raw.githubusercontent.com/MGertz/k8s/main/node.sh | sudo sh
```





