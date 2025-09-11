def main():
    original_function = '''def _compute_packages_changes(self):'''

    replacement_function = '''def _compute_packages_changes(self):
        import cProfile
        import pstats
        from datetime import datetime
        import psutil

        profile = cProfile.Profile()
        process = psutil.Process()
        start_cpu_times = process.cpu_times()
        profile.enable()

        result = self.compute_packages_change_inner()

        end_cpu_times = process.cpu_times()

        profile.disable()

        user_time = end_cpu_times.user - start_cpu_times.user
        system_time = end_cpu_times.system - start_cpu_times.system
        total_cpu_time = user_time + system_time

        output_path = "/var/lib/landscape/client/result.txt"
        with open(output_path, "a") as fp:
            now = datetime.now()
            fp.write(f"\\n--------- Run on: {now.strftime('%Y-%m-%d %H:%M:%S')} ---------\\n\\n")
            stats = pstats.Stats(profile, stream=fp)
            stats.strip_dirs().sort_stats("cumulative").print_stats(10)
            fp.write(f"CPU Time: {total_cpu_time}s\\n")
        return result

    def compute_packages_change_inner(self):'''

    file_path = '/usr/lib/python3/dist-packages/landscape/client/package/reporter.py'

    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        modified_content = content.replace(original_function, replacement_function)
        
        with open(file_path, 'w') as f:
            f.write(modified_content)

    except Exception as e:
        print(f"Error adding benchmarking: {str(e)}")

if __name__ == "__main__":
    main()
