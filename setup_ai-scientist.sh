# NanoGPTデータの準備:
python data/enwik8/prepare.py
python data/shakespeare_char/prepare.py
python data/text8/prepare.py

# nano gptベースライン実行:
cd templates/nanoGPT
python experiment.py --out_dir run_0
python plot.py

cd templates/nanoGPT_lite
python experiment.py --out_dir run_0
python plot.py

# ai scientist の実行
# python launch_scientist.py --model "gpt-4o-2024-05-13" --experiment nanoGPT_lite --num-ideas 3