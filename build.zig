const std = @import("std");

pub fn build(b: *std.Build) void {
    const cuda = b.option(bool, "cuda", "Build with ZML's CUDA backend") orelse false;
    const cuda_runtime = b.option([]const u8, "cuda-runtime", "CUDA runtime library to preload") orelse "/usr/local/cuda-13.0/lib64/libcudart.so.13";

    const build_cmd = b.addSystemCommand(&.{ "npx", "--yes", "@bazel/bazelisk", "build" });
    addCudaFlag(build_cmd, cuda);
    build_cmd.addArg("//zml");
    b.default_step.dependOn(&build_cmd.step);

    const test_cmd = b.addSystemCommand(&.{ "npx", "--yes", "@bazel/bazelisk", "test" });
    addCudaFlag(test_cmd, cuda);
    test_cmd.addArgs(&.{ "//zml:test", "//stdx:test", "//zml/tokenizer:test" });
    const test_step = b.step("test", "Run ZML core and tokenizer tests");
    test_step.dependOn(&test_cmd.step);

    const mnist_cmd = b.addSystemCommand(&.{ "npx", "--yes", "@bazel/bazelisk", "run" });
    addCudaFlag(mnist_cmd, cuda);
    setCudaRuntime(mnist_cmd, cuda, cuda_runtime);
    mnist_cmd.addArg("//examples/mnist");
    mnist_cmd.addArg("--");
    mnist_cmd.addPassthruArgs();
    const mnist_step = b.step("mnist", "Run the MNIST example");
    mnist_step.dependOn(&mnist_cmd.step);

    const llm_cmd = b.addSystemCommand(&.{ "npx", "--yes", "@bazel/bazelisk", "run" });
    addCudaFlag(llm_cmd, cuda);
    setCudaRuntime(llm_cmd, cuda, cuda_runtime);
    llm_cmd.addArg("//examples/llm");
    llm_cmd.addArg("--");
    llm_cmd.addPassthruArgs();
    const llm_step = b.step("llm", "Run the LLM example");
    llm_step.dependOn(&llm_cmd.step);
}

fn addCudaFlag(cmd: *std.Build.Step.Run, cuda: bool) void {
    if (cuda) cmd.addArg("--@zml//platforms:cuda=true");
}

fn setCudaRuntime(cmd: *std.Build.Step.Run, cuda: bool, cuda_runtime: []const u8) void {
    if (cuda) cmd.setEnvironmentVariable("LD_PRELOAD", cuda_runtime);
}
