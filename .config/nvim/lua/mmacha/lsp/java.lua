-- JDTLS needs Java 21+, independently of the JDK used by project builds.
-- Other machines can use `brew install openjdk@21` or set JDTLS_JAVA_HOME.
local server_home = vim.env.JDTLS_JAVA_HOME
if not server_home or server_home == "" then
    server_home = nil
    for _, path in ipairs({
        vim.fn.stdpath("data") .. "/jdks/temurin-21",
        "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
        "/usr/local/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
    }) do
        if vim.fn.executable(path .. "/bin/java") == 1 then
            server_home = path
            break
        end
    end
end

local runtimes = {}
local project_home = vim.env.JAVA_HOME
if project_home and project_home ~= "" then
    local ok, release = pcall(vim.fn.readfile, project_home .. "/release")
    if ok then
        local version = table.concat(release, "\n"):match('JAVA_VERSION="(%d+)')
        if version then
            runtimes[1] = { name = "JavaSE-" .. version, path = project_home, default = true }
        end
    end
end

return {
    cmd_env = server_home and { JAVA_HOME = server_home } or nil,
    settings = {
        java = {
            configuration = { runtimes = runtimes },
        },
    },
}
