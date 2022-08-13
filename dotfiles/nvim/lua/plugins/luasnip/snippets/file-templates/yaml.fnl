(local {: s : i : rep : fmta : read_template_file : o_file_start}
       (require :plugins.luasnip.snippets.utils))

[(s :initk8sdep
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/Deployment.yaml
    ; ./files/yaml-k8sdep.yml
    (fmta (read_template_file :yaml-k8sdep.yml)
          [(i 1 :nginx)
           (i 2 :nginx)
           (i 3 :3)
           (rep 2)
           (rep 2)
           (i 4 :nginx)
           (i 5 "nginx:1.14.2")
           (i 6 :80)]) o_file_start)
 (s :initk8sser
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/Service.yaml
    ; ./files/yaml-k8sser.yml
    (fmta (read_template_file :yaml-k8sser.yml)
          [(i 1 :my-service) (i 2 :MyApp) (i 3 :80) (i 4 :9376)])
    o_file_start)
 (s :initk8sing
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/Ingress.yaml
    ; ./files/yaml-k8sing.yml
    (fmta (read_template_file :yaml-k8sing.yml)
          [(i 1 :minimal-ingress)
           (i 2 :/testpath)
           (i 3 :Prefix)
           (i 4 :test)
           (i 5 :80)]) o_file_start)
 (s :initk8spvc
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/PersistentVolumeClaim.yaml
    ; ./files/yaml-k8spvc.yml
    (fmta (read_template_file :yaml-k8spvc.yml)
          [(i 1 :myclaim) (i 2 :ReadWriteOnce) (i 3 :8Gi) (i 4 :slow)])
    o_file_start)
 (s :initk8ssec
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/Secret.yaml
    ; ./files/yaml-k8ssec.yml
    (fmta (read_template_file :yaml-k8ssec.yml)
          [(i 1 :secret-basic-auth)
           (i 2 :kubernetes.io/basic-auth)
           (i 3 :admin)
           (i 4 :t0p-Secret)]) o_file_start)
 (s :initk8scom
    ; https://github.com/lensapp/lens/blob/master/templates/create-resource/ConfigMap.yaml
    ; ./files/yaml-k8scom.yml
    (fmta (read_template_file :yaml-k8scom.yml) [(i 1 :game-demo)]) o_file_start)]
