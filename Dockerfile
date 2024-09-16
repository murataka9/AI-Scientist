# CUDAサポート付きの公式PyTorchイメージを使用
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive

# 必要なLinuxパッケージをインストール
RUN apt-get update && apt-get install -y \
    texlive-full \
    git \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Minicondaのインストール
RUN curl -o /tmp/miniconda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh

# Condaコマンドを使えるように環境変数PATHに追加
ENV PATH=/opt/miniconda/bin:$PATH

# Condaをbashシェルで初期化し、bashrcを更新
RUN /opt/miniconda/bin/conda init bash

# .bashrcをソースしてConda環境を有効化
RUN bash -c "source /root/.bashrc && conda create -n ai_scientist python=3.11 -y && conda activate ai_scientist"

# デフォルトシェルをbashに設定
SHELL ["/bin/bash", "-c"]

# 作業ディレクトリを設定し、コードをコピー
WORKDIR /workspace
COPY . .

# Python依存パッケージをインストール
RUN /opt/miniconda/bin/conda run -n ai_scientist pip install -r requirements.txt

# NPEETリポジトリのクローンとインストール
RUN git clone https://github.com/gregversteeg/NPEET.git && \
    cd NPEET && /opt/miniconda/bin/conda run -n ai_scientist pip install .

# エントリーポイントをbashシェルで実行
ENTRYPOINT ["/bin/bash", "-c", "source /root/.bashrc && conda activate ai_scientist && exec /bin/bash"]
